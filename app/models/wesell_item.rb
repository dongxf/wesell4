#encoding: utf-8
class WesellItem < ActiveRecord::Base
  belongs_to :store
  belongs_to :category

  has_many :order_items, dependent: :restrict_with_exception
  has_many :orders, through: :order_items

  has_many :options_groups, dependent: :destroy
  has_many :wesell_item_options
  has_many   :comments, dependent: :destroy, as: :commentable

  mount_uploader :image, ImageUploader
  mount_uploader :banner, BannerUploader

  STATUS = {
    "不限量供应" => 0,
    "限量供应" => 1,
    "等待发售" => 2,
    # "下架"      => 10
  }

  RULE = {
    "普通" => "rule",
    "限制"  => "showroom"
  }

  def human_status
    yxj = { 'normal' => '已下架', 'event' => '已过期'}
    dks = { 'normal' => '待开售', 'event' => '即将开放报名' }
    ysq = { 'normal' => '已售罄', 'event' => '名额已报满' }
    ys_ = { 'normal' => '已售', 'event' => '已报' }


    return yxj[self.store.stype] if status >= 10
    return dks[self.store.stype]  if status == 2
    return quantity <=0 ? " #{ysq[self.store.stype]}" : "" if status == 1
    return  total_sold > 0 ? "#{ys_[self.store.stype]}#{total_sold}#{unit_name}" : ""
  end

  validates_presence_of :name, :quantity, :price, :unit_name, :status, :sequence
  # validates_uniqueness_of :name, scope: [:store_id, :status]
  # validates_numericality_of :price, greater_than: 0
  validates_numericality_of :original_price, :quantity, greater_than_or_equal_to: 0
  validates_length_of :description, maximum: 140

  delegate :monetary_unit, :monetary_tag, to: :store

  default_scope { order('wesell_items.sequence ASC') }
  scope :online, -> { where('deleted = false AND status < 10') }
  scope :offline, -> { where('deleted = false AND status = 10') }
  scope :undeleted, -> { where(deleted: false) }

  after_save :update_counter_cache
  after_destroy :update_process

  after_update :update_order_items, :if => :price_changed?

  searchable do
    text    :name,        stored: true
    text    :description, stored: true
    integer :total_sold
    integer :store_id
  end

  def update_order_items
    self.order_items.each do |i|
      new_price = self.price
      i.unit_price = new_price
      i.save
    end
  end

  def show_buyers?
    return self.store.show_buyers
    #return false if self.store.id != 3408 && self.store.id != 1 #this is a quick way
    #return true
  end

  def show_visitors?
    return false if self.store.id != 3408 && self.store.id != 1 #this is a quick way
    return true
  end

  def buyers
    bs = []
    self.orders.unopen.pluck(:customer_id).uniq.each { |cid| bs << Customer.find_by(id: cid) }
    return bs
  end

  def visitors 
    bs = []
    self.orders.open.pluck(:customer_id).uniq.each { |cid| bs << Customer.find_by(id: cid) }
    return bs
  end

  def human_price mystore=nil
    mystore ||= store
    "#{mystore.monetary_tag}#{price}/#{unit_name}"
  end

  def human_original_price mystore=nil
    mystore ||= store
    "#{mystore.monetary_tag}#{original_price}/#{unit_name}"
  end

  def the_order_by buyer
    buyer.orders.each do |order|
      return order if order.wesell_items.include? self
    end
  end

  def category_name
    category.name if category
  end

  def add_to_order order
    OrderItem.find_or_initialize_by({
      order_id:       order.id,
      wesell_item_id: self.id,
      category_id:    self.category_id,
      name:           self.name,
      unit_price:     self.price,
      unit_name:      self.unit_name
    })
  end


  def data_hash
    { product_id: self.id,
      dishid: self.id,
      dunitname: self.unit_name,
      dsubcount: self.total_sold,
      dname: self.name,
      dtaste: "",
      ddescribe: self.description,
      dprice: self.price,
      dishot: "2",
      dspecialprice: self.original_price,
      disspecial: "1",
      shopinfo: ""}
  end

  #下架
  def offline
    update_attribute :status, 10
  end

  def offline?
    status >= 10
  end

  def online?
    !offline?
  end

  def online
    update_attribute :status, 0
  end

  def delete!
    update_attributes deleted: true
  end

  def sold_out?
    if status == 0
      return false
    elsif quantity <= 0
      return true
    end
  end

  def human_stock
    status == 0 ? '不限量供应' : "库存#{quantity}#{unit_name}"
  end

  def copy! options = {}
    item_copy       = self.dup
    item_copy.oldid = nil
    item_copy.name  = options[:name] if options.present?
    if item_copy.save
      self.options_groups.each do |option_group|
        option_group_copy                = option_group.dup
        option_group_copy.wesell_item_id = item_copy.id
        option_group_copy.oldid          = nil

        if option_group_copy.save(validate: false)
          option_group.wesell_item_options.each do |option|
            option_copy                  = option.dup
            option_copy.wesell_item_id   = option_group_copy.wesell_item_id
            option_copy.options_group_id = option_group_copy.id
            option_copy.save(validate: false)
          end
        end
      end
    end
    item_copy
  end

  def update_counter_cache
    if self.changes[:store_id].present? || self.changes[:deleted]
      self.update_process
      # Store.find(self.changes[:store_id].compact).each do |store|
      #   store.wesell_items_count = WesellItem.where("deleted = false AND store_id = ?", store.id).count
      #   store.save
      # end
    end
    if self.changes[:category_id].present?
      Category.find(self.changes[:category_id].compact).each do |category|
        category.products_count = WesellItem.where("deleted = false AND category_id = ?", category.id).count
        category.save(validate: false)
      end
    end
  end

  def update_process
    # logger.info "======== true ========="
    # logger.info "======== #{self.changes} ========="
    store = self.store
    store.wesell_items_count = WesellItem.where("deleted = false AND store_id = ?", store.id).count
    store.save(validate: false)
  end
end
