#encoding: utf-8
require 'monetary'

class Store < ActiveRecord::Base
  include Monetary
  include Ownable
  include Operatable
  include StoreConfig
  include Bindable

  geocoded_by :street

  has_many :operations, dependent: :destroy
  has_many :instances, through: :operations
  has_many :showrooms, through: :instances

  belongs_to :creator, class_name: 'User'

  has_many :categories, dependent: :destroy
  has_many :wesell_items, dependent: :destroy
  has_many :other_wesell_items, -> { where('wesell_items.category_id is ?', nil) }, class_name: 'WesellItem'
  has_many :orders, dependent: :restrict_with_exception
  has_many :order_configs
  has_many :customers, -> { uniq }, through: :orders
  has_many :printers
  has_many :reports, dependent: :destroy

  has_many :express_stores, dependent: :destroy
  has_many :expresses, through: :express_stores
  has_many :village_item

  scope :opening,   -> { where(open: true) }
  scope :undeleted, -> { where(deleted: false) }
  scope :online,    -> { where(deleted: false) }
  scope :offline,   -> { where(deleted: true) }
  scope :localized, -> { where('service_radius > 0') }

  mount_uploader :logo, LogoUploader
  mount_uploader :banner, BannerUploader

  attr_accessor :instance_id, :distance

  validates :name, :description, :phone, :email, :street, :time_setting, :address_setting, presence: true
  validates_format_of :phone, with: PHONE_REGEXP, message: '手机座机传呼机，6-12位号码'
  # validates_format_of :email, with: Devise::email_regexp
  validates_format_of :email, :with => MULTIPLE_EMAIL_REGEXP
  validates_format_of :opening_hours, with: /\A(\d{2}:\d{2}~\d{2}:\d{2})(,\d{2}:\d{2}~\d{2}:\d{2})*\z/,
                      message: '格式不对, 数字用~连接, 多个时段用逗号分隔, 不要空格', allow_blank: true
  validates_presence_of :latitude, :longitude, if: 'service_radius.present?'
  validate :check_charge_option

  after_create :gen_invite_code


  STYPE = {
    normal: '标准商店',
    event: '活动预约'
  }

  TIME_SETTING = {
    nodate:   '无需指定日期（如：点外卖）',
    # date:     '需要指定日期（如：预定客房）',
    datetime: '指定日期与时间（如：预约钟点工，订客房）'
  }
  symbolize :time_setting, in: TIME_SETTING.keys, scopes: :shallow, methods: true, default: :nodate

  ADDRESS_SETTING = {
    noaddress:      '无需指定地址（如：预定客房）',
    address:        '需要指定地址（如：外卖，店内自助，钟点工上门）'
    # optional_address: '店外地址或店内消费（如：餐厅提供外送或者自助点餐）'
  }
  symbolize :address_setting, in: ADDRESS_SETTING.keys, scopes: :shallow, methods: true, default: :address


  SHIPPING_CHARGE_OPTIONS = {
    '低于最低消费禁止下单'            => 0,
    '低于最低消费收取运费'            => 1,
    '每单收取运费，低于最低消费禁止下单' => 2
  }

  searchable do
    text :name,    stored: true
    text :phone,   stored: true
    text :email,   stored: true
    text :street,  stored: true
    integer :id
  end

  def self.copy! id, options = {}
    store = Store.find id
    store.copy! options if store.present?
  end

  def gen_invite_code
    update_column :invite_code, SecureRandom.hex(4)
  end

  def human_status

  end

  def human_template
    TEMPLATES[template.to_sym]
  end

  def popular
    self.wesell_items.order(:total_sold).last
  end

  def is_open?
    return false if !open? || deleted?
    return true if opening_hours.blank?
    current = Time.zone.now.strftime('%H:%M')
    ranges = opening_hours.split(',')
    ranges.each do |range|
      i1, i2 = *range.split('~')
      return true if i1 <= current && current <= i2
    end
    return false
  end

  def open_status
    msg = open? ? "营业时间：" : ''
    msg << human_opening_hours
  end

  def human_opening_hours
    msg = ''
    if open?
      if opening_hours.present?
        ranges = opening_hours.split(',')
        ranges.each do |range|
          i1, i2 = *range.split('~')
          msg << "(#{i1} ~ #{i2})"
        end
      elsif open?
        msg << '(24小时营业)'
      end
    else
      msg << '(打烊中)'
    end
    msg
  end

  def get_kategory instance
    return nil unless self.instances.include? instance
    self.operations.where('operations.instance_id = ?', instance.id).first.kategory
  end

  def set_kategory kategory, instance = nil
    if kategory
      instance = kategory.instance
      operation = self.operations.where('operations.instance_id = ?', instance.id).first
      operation.update_attribute :kategory_id, kategory.id if operation.present?
    elsif instance
      operation = self.operations.where('operations.instance_id = ?', instance.id).first
      operation.update_attribute :kategory_id, nil
    end
  end

  def disappear
    operations.destroy_all
    update_attribute :deleted, true
  end

  def human_distance
    if distance.present?
      if distance > 1
        "距离#{self.distance.round(2)}公里"
      else
        "距离#{(self.distance*1000).round}米"
      end
    else
      ''
    end
  end

  def check_charge_option
    if min_charge > 0
      errors.add(:shipping_charge_option, "您设置了最低消费，请设置最低消费的使用策略") if shipping_charge_option.blank?
    end
  end

  def shipping_charge_tips
    case shipping_charge_option
    when nil
      "每单收取运费#{shipping_charge}#{monetary_unit}" if shipping_charge > 0
    when 1
      "本店最低消费：#{min_charge}#{monetary_unit}，低于最低消费收取运费#{shipping_charge}#{monetary_unit}"
    when 2
      "每单收取运费#{shipping_charge}#{monetary_unit}"
    end
  end

  def located?
    latitude.present? && longitude.present?
  end

  def default_instance
    return nil unless instances.present?
    instance = instances.where('name <> ?', 'foowcn').first
    instance ||= instances.first
  end

  # a foowable store means it's qualified to be invited for joining foowcn
  # to be foowable, a store must be:
  # - locatable
  # - with a reasonable service radius; or has a global mark
  # - has been ordered by at least 3 customers for recent 30 orders
  # - has been ordered at least 7 orders within past 7 days
  def foowable?
    store = self
    week_end=Time.now.yesterday.end_of_day
    week_start=week_end.ago(7.days)
    drt=week_start..week_end
    return false if !store.located?
    return false if store.service_radius.nil?
    return false if store.service_radius > 1500.0 #need to improve later
    return false if store.orders.limit(30).pluck(:customer_id).uniq.count < 3
    return false if store.orders.where(submit_at: drt).count < 7
    return true
  end

  def copy! options = {}
    store_copy            = self.dup
    store_copy.oldid      = nil
    store_copy.name       = options[:name] if options.present?
    if store_copy.save(validate: false)
      store_copy.remote_logo_url   = self.logo.url

      store_copy.remote_banner_url = self.banner.url
      self.managers.each do |manager|
        store_copy.add_manager manager
      end
      self.instances.each do |instance|
        store_copy.add_operation instance
      end
      self.order_configs.each do |config|
        config_copy          = config.dup
        config_copy.store_id = store_copy.id
        config_copy.save(validate: false)

        config.order_config_options.each do |config_option|
          config_option_copy                 = config_option.dup
          config_option_copy.order_config_id = config_copy.id
          config_option_copy.store_id        = store_copy.id
          config_option_copy.save(validate: false)
        end
      end
      # 复制有目录的商品
      self.categories.each do |cate|
        cate_copy          = cate.dup
        cate_copy.store_id = store_copy.id
        cate_copy.oldid    = nil
        cate_copy.save(validate: false)

        cate.wesell_items.online.each do |item|
          item_copy             = item.dup
          item_copy.category_id = cate_copy.id
          item_copy.store_id    = store_copy.id
          item_copy.oldid       = nil
          item_copy.remote_image_url  = item.image.url
          item_copy.remote_banner_url = item.banner.url
          item_copy.save(validate: false)

          item.options_groups.each do |option_group|
            option_group_copy                = option_group.dup
            option_group_copy.wesell_item_id = item_copy.id
            option_group_copy.oldid          = nil
            option_group_copy.save(validate: false)

            option_group.wesell_item_options.each do |option|
              option_copy                = option.dup
              option_copy.wesell_item_id   = option_group_copy.wesell_item_id
              option_copy.options_group_id = option_group_copy.id
              option_copy.save(validate: false)
            end
          end
        end
      end
      # 复制无目录商品
      other_wesell_items.online.each do |item|
        item_copy             = item.dup
        item_copy.store_id    = store_copy.id
        item_copy.oldid       = nil
        item_copy.remote_image_url  = item.image.url
        item_copy.remote_banner_url = item.banner.url
        item_copy.save(validate: false)

        item.options_groups.each do |option_group|
          option_group_copy                = option_group.dup
          option_group_copy.wesell_item_id = item_copy.id
          option_group_copy.oldid          = nil
          option_group_copy.save(validate: false)

          option_group.wesell_item_options.each do |option|
            option_copy                  = option.dup
            option_copy.wesell_item_id   = option_group_copy.wesell_item_id
            option_copy.options_group_id = option_group_copy.id
            option_copy.save(validate: false)
          end
        end
      end
    end
    store_copy
  end
end
