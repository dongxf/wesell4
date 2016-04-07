class VillageItem < ActiveRecord::Base
  require 'csv'
  include Bindable

	belongs_to :store
  belongs_to :instance
	has_many   :taggings, dependent: :destroy
	has_many   :favors,   dependent: :destroy
	has_many   :comments, dependent: :destroy, as: :commentable
	has_many   :sub_tags, through:   :taggings
	has_many   :tags,     through:   :sub_tags
  has_many   :offers,   dependent: :destroy
  has_many :leagueships, dependent: :destroy
  has_many :villages, through: :leagueships
  has_many :user_village_items, dependent: :destroy

	validates :name, presence: true, :uniqueness => {:scope => :village_id}
	validates :tel, presence: true, format: { with: PHONE_REGEXP, message: '手机座机传呼机，6-12位号码' }, :uniqueness => true
	validates_format_of :opening_hours, with: /\A(\d{2}:\d{2}~\d{2}:\d{2})(,\d{2}:\d{2}~\d{2}:\d{2})*\z/,
	                    message: '格式不对, 数字用~连接, 多个时段用逗号分隔, 不要空格', allow_blank: true

	mount_uploader :logo, ViLogoUploader
  mount_uploader :banner, ViBannerUploader

	mount_uploader :doc, AttachmentUploader
  scope :permit, -> { where.not(level: 0) }

  before_create :gen_pin

	searchable do
	  text :name,    stored: true
	  text :tel,     stored: true
	  text :info,    stored: true
	  text :meta
    integer :level
	  integer :instance_id
    integer :village_ids, :multiple => true
	  integer :id
    integer :vscore
	end

	has_settings do |s|
    s.key :fbook, defaults: { takeout: false }
  end

  LEVEL = {
    '禁用' => 0,
    '普通' => 1,
    'A套餐(201407)' => 2,
    'B套餐(201407)' => 3,
    'A套餐(201503)' => 4,
    'B套餐(201503)' => 5
  }

  def foo_url?
    return true if self.entry_url.blank? || self.entry_url.include?('fooways.com') || self.entry_url.include?('127.0.0.1')
    return false
  end

  def self.import csv_file, instance_id
    h = ["village_id", "name", "tel", "addr", "opening_hours","takeout", "info", "meta", "sub_tags", "user_email", "remark"]
    csv_read = CSV.read csv_file.path, headers: true
    new_csv = CSV.open(csv_file.path, 'w') do |csv|
      csv << h
      csv_read.each_with_index do |row|
        csv.puts row
      end
    end.delete_if { |row| row.to_hash.values.all?(&:blank?) }

    csv_read = CSV.read(csv_file.path, headers: true).delete_if { |row| row.to_hash.values.all?(&:blank?) }

    csv_read.each do |row|
      unless VillageItem.exists? tel: row["tel"]
        sub_tags = row["sub_tags"].split(/,|，/) if row["sub_tags"]
        user_email = row["user_email"]
        village_ids = row["village_id"]
        takeout = row["takeout"] == "是" ? true : false
        attrs = row.to_hash.merge({level: 1, instance_id: instance_id, takeout: takeout})
        attrs.delete nil
        attrs.delete 'sub_tags'
        attrs.delete 'user_email'
        attrs.delete 'village_id'
        vi = VillageItem.new attrs
        vi.save(validate: false)

        vi.sub_tag_list = sub_tags if sub_tags
        vi.village_list = village_ids
        user = User.find_by email: user_email
        UserVillageItem.create(user_id: user.id, village_item_id: vi.id) if user.present?
      end
    end
  end

  def self.has_offers
    self.all.includes(:offers).select { |vi| vi.offer_available? }
  end

  # this method need to be migrated to an active record attribute for performance consideration
  def offer_available?
    #return self.approved? && self.offers.last.present? && self.offers.last.effective?
    return self.offers.last.present? && self.offers.last.effective?
  end

  def owner_user
    vos = Ownership.find_by target_id: self.id, target_type: 'VillageItem', role_identifier: 'owner'
    return vos.present? ? vos.user : vos
  end

  def notify_binders event_type, customer#, vi
    vi=self
    return false if customer.nil? 
    ce=CustomerEvent.create(customer_id: customer.id,target_id:vi.id,target_type:vi.class.to_s, duration:Time.now,frequency:'real_time',event_type:event_type.to_s,event_count:1,name:'customer_click_village_item',url:'',comment:'')
    cname = (customer.subscribed?&&customer.openid.present?) ? "#{customer.nickname}(#{customer.instance.id}-#{customer.id})" : "游客#{customer.current_visit_ip}"
    fb_form = "#{vi.name}"
    case event_type
    when :favor_event
      fb_note = "#{cname}收藏了黄页条目"
    when :unfavor_event
      fb_note = "#{cname}取消了条目收藏"
    when :show_event
      fb_note = "#{cname}在浏览黄页信息"
    when :call_event
      fb_note = "#{cname}点击了拨打电话"
    when :view_event
      fb_note = "#{cname}点击了店铺详情"
    when :shop_event
      fb_note = "#{cname}点击了在线订购"
    else
      return false
    end
    fwdesk = Instance.find_by name: 'fwdesk'
    fwdesk_app = WechatApp.new fwdesk
    text = {
      first: "黄页条目状态变动通知",
      fb_form: fb_form,
      fb_note: fb_note,
      area: "小区黄页@#{vi.instance.nick}",
      remark: "发现身边之美，共构社区精彩"
    }
    vi.binderers.each do |binderer|
      text[:url] = "#{ENV['WESELL_SERVER']}/community/village_items/#{vi.id}?instance_id=#{vi.instance.id}&notifier=true"
      fwdesk_app.send_template fwdesk.template_id, binderer.openid, text
    end
    return true
  end

  def takeout
  	settings(:fbook).takeout
  end

  def takeout=(val)
  	self.settings(:fbook).takeout = val
  end

  def takeout?
  	(takeout == true || takeout == '1') ? true : false
  end

  def invalid?
    level == 0
  end

  def normal?
    level == 1
  end

  # level will be reset to 1 for those approved_end_at expired in daily rake

  def junior?
    level == 2 || level == 4
  end

  def senior?
    level == 3 || level == 5
  end

  def approved?
    junior? || senior?
  end

  def enterable?
    #self.approved? && ( self.entry_url =~ URI::regexp ) == 0
    #( self.entry_url =~ URI::regexp ) == 0 #"javascript:void(0)" will pass regexp
    self.approved? && ( self.entry_url =~ /\A#{URI::regexp(['http', 'https'])}\z/ ) == 0
  end

	def self.list_sort  #no need?
    self.all.sort_by(&:weight).reverse
	end

	def weight
    #vscore will be generated periodically in crontab
    vscore
	end

  ##############  Tag & SubTag
	def self.find_with_tag(tag, village=nil, instance=nil)
    if village
  	  Tag.find_by_name!(tag).village_items.select {|vi| vi.villages.include? village}.uniq
    elsif instance
      Tag.find_by_name!(tag).village_items.where(instance: instance).uniq
    end
	end
  # to refactor the same method
	def self.find_with_sub_tag(sub_tag, village=nil, instance=nil)
    if village
	    SubTag.find_by_name!(sub_tag).village_items.select {|vi| vi.villages.include? village}.uniq
    elsif instance
      SubTag.find_by_name!(sub_tag).village_items.where(instance: instance).uniq
    end
	end

	def sub_tag_list
	  sub_tags.pluck(:name).join(", ")
	end

	def sub_tag_list=(names)
		names.reject!(&:blank?) #  where the blank element come from?
	  self.sub_tags = names.map do |n|
	    SubTag.where(name: n.strip).first
	  end.compact
	end

  def village_list=(v_ids)
    village_list_ids = v_ids.split(/,|，/).map(&:to_i)
    self.villages = Village.where(id: village_list_ids)
  end

	############ Favor
	def favor_by?(customer)
		Favor.exists?(customer_id: customer.id, village_item_id: self.id)
	end

	def favor_by(customer)
	  if Favor.exists?(customer_id: customer.id, village_item_id: self.id)
	    # already favor, remove it
	    ActiveRecord::Base.transaction do
	      Favor.delete_all(customer_id: customer.id, village_item_id: self.id)
	      self.decrement!(:favor_count)
        self.notify_binders :unfavor_event, customer
	    end
	  else
	    # not favor yet, add it
	    ActiveRecord::Base.transaction do
	      Favor.create!(customer_id: customer.id, village_item_id: self.id)
	      self.increment!(:favor_count)
        self.notify_binders :favor_event, customer
	    end
	  end
	end

  def valid_url?
    url && URI.regexp =~ url
  end

  def has_valid_westore?
    store_id.present? && instance.stores.include?(store)
  end

  def westore_url
    return "#{ENV['WESELL_SERVER']}/westore/instances/#{instance.id}/stores/#{store_id}" if Rails.env.production?
    return "http://127.0.0.1:8080/westore/instances/#{instance.id}/stores/#{store_id}"
  end

  def entry_url
    return url if valid_url?
    return westore_url if has_valid_westore?
    return "#{ENV['WESELL_SERVER']}/community/village_items/#{id}/page" unless self.page.blank?
    return "javascript:void(0)"
  end

  def human_opening_hours
    msg = ''
    if opening_hours.present?
      ranges = opening_hours.split(',')
      ranges.each do |range|
        i1, i2 = *range.split('~')
        msg << " #{i1} ~ #{i2} "
      end
    elsif
      msg << '24小时营业'
    end
    msg
  end

  def gen_pin
    loop do
      token = SecureRandom.hex(4)
      break self.pin = token unless VillageItem.exists?(pin: token)
    end
  end

  def gen_sceneid
    return self.sceneid if self.sceneid.present?
    # sceneid assignment not pretty good.
    loop do
      sid = rand(100..100000)
      break self.sceneid = sid unless ( self.instance.village_items.exists?(sceneid: sid) && self.instance.operations.exists?(sceneid: sid) )
    end
    save
    return self.sceneid
  end
end
