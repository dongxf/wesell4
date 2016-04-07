class Customer < ActiveRecord::Base
  belongs_to :instance, counter_cache: true
  belongs_to :operator, class_name: 'Instance', foreign_key: 'operator_id'
  belongs_to :member
  has_many :orders
  has_many :lotteries
  has_many :favors, dependent: :destroy
  has_many :village_items, through: :favors
  has_many :comments, dependent: :destroy
  has_many :records, dependent: :destroy
  has_many :binders, dependent: :destroy
  has_one :location

  scope :sub, -> { where(subscribed: true) }
  scope :unsub, -> { where(subscribed: false && :openid != nil) }
  scope :identified, -> { where(:openid != nil) } #wait for opendid!=nil || qqid!=nil etc.

  # validates_each :lotteries do |customer, attr, value|
  #   首单送彩票 ?????
  #   customer.errors.add attr, "你已经领过一次彩票了"  if  customer.lotteries.size > 1
  # end

  STATUS = {
    '正常'    => 0,
    '黑名单'   => 1
  }

  before_create :gen_cid

  def gen_cid
    begin
      cid = SecureRandom.hex(16)
    end while Customer.exists?(cid: cid)
    self.cid = cid
  end

  def tips
    tips = []
    if self.instance.float_mechat_url.present? && self.cs_tip.present?
      tips << self.cs_tip
      self.update_attributes(cs_tip: '')
    end
    return tips
  end

  def get_tip!
    return self.tips.first
  end

  def gen_cid!
    gen_cid
    self.save
  end

  def init_order instance, store
    raise 'Store is blank'    if store.blank?
    raise 'Instance is blank' if instance.blank?
    last_order = self.orders.unopen.where(store_id: store.id).first
    last_order ||= self.orders.unopen.first
    order = Order.find_or_initialize_by store_id: store.id, instance_id: instance.id, customer_id: self.id, status: 'open'
    if last_order.present?
      order.contact = last_order.contact
      order.phone   = last_order.phone
      order.address = last_order.address if store.address?
    end
    order.save(validate: false) if order.changed?
    order
  end

  def showroom_purchased_item_count sr
        return 0 if sr.class.name != 'Showroom'
        #sr = Showroom.find wesell_item.showroom_id
        purchased = 0
        wss=WesellItem.where(showroom_id: sr.id)
        wss.each { |ws| purchased += purchased_wesell_item_count(ws) }
        return purchased
  end

  def purchased_wesell_item_count ws
    cnt = 0
    self.orders.where('submit_at IS NOT NULL').each do |order|
      order.order_items.each do |oi|
        cnt += oi.quantity if oi.wesell_item_id == ws.id
      end
    end
    return cnt
  end

  def located?
    location.present? #&& !location.expired?
  end

  def consumption
    orders.successful.sum(:amount)
  end

  def human_status
    STATUS.key(status)
  end

  def default_instance
    operator.present? ? operator : instance
  end

  def set_default_instance instance
    operator_id = instance.id
    self.save
  end

  def normal?
    status == 0
  end

  def unsubscribe
    update_attributes subscribed: false, operator_id: nil
  end

  def subscribe
    update_attribute :subscribed, true
  end

  def send_form summary, title, note, url
    ii = self.instance
    return if ii.blank?
    wa = WechatApp.new (ii)
    text = {
      first: summary,
      area: ii.nick,
      url: url,
      remark: "服务电话：#{ii.phone}",
      fb_form: title,
      fb_note: "#{note}"
    }
    wa.send_template ii.template_id, self.openid, text
  end

  def send_event_notice summary, key1, key2, key3, key4, remark, url
    ii=self.instance
    return if ii.blank?
    tpid = 'DdIvdmngmMB7lX9bLJK9F3vZBieHd81Q3oKL_a2CieY' #new registration
    tpid = 'ByerDLJbYLp5U38TdFPJ78zUgy93AFIwDQ4e5SxKGzg' #coming soon
    wa = WechatApp.new (ii)
    text = {
      first: summary,
      keyword1: key1,
      keyword2: key2,
      keyword3: key3,
      keyword4: key4,
      remark: remark,
      url: url
    }
    wa.send_template tpid, self.openid, text
  end

  def set_default_village
    return false if self.default_village_id.present?
    return false if self.instance.villages.empty?
    return self.update_attributes(default_village_id: self.instance.villages.first)
  end

  def register_member order
    _member = self.member

    if _member.blank?
      _member = Member.new instance_id: self.instance_id,
                          name:        order.contact,
                          phone:       order.phone,
                          address:     order.address
      _member.save(validate: false)
      self.member_id = _member.id
      save
    end
    _member
  end

  def ever_buy? wesell_item
    wesell_item.orders.where("submit_at IS NOT NULL").pluck(:customer_id).include?(self.id)
  end
end
