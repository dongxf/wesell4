#encoding: utf-8
require 'creditable'
require 'locatable'

class Instance < ActiveRecord::Base
  include Locatable
  include Ownable
  include Operatable
  include Creditable
  include InstanceConfig
  include Spreadable
  include Bindable

  has_many :wechat_menus, -> {order 'sequence asc'}
  has_many :wechat_sub_menus, through: :wechat_menus

  has_many :operations, dependent: :destroy
  has_many :stores, through: :operations

  has_many :showrooms, dependent: :destroy

  has_many :kate_operations, -> {where('operations.kategory_id is not ?', nil)}, class_name: 'Operation'
  has_many :other_operations, -> {where('operations.kategory_id is ?', nil)}, class_name: 'Operation'

  has_many :kate_stores, through: :kate_operations, class_name: 'Store', source: 'store'
  has_many :other_stores, through: :other_operations, class_name: 'Store', source: 'store'

  has_many :kategories
  has_many :valid_kategories, -> {where('kategories.stores_count > ?', 0)}, class_name: 'Kategory'

  belongs_to :creator, class_name: 'User'

  has_many :orders, dependent: :restrict_with_exception
  has_many :customers
  has_many :members, through: :customers

  has_many :wechat_keys

  # has_one :village, dependent: :destroy
  has_many :villages, dependent: :destroy
  has_many :village_items, dependent: :destroy
  has_many :comments, through: :village_items
  has_many :records, dependent: :destroy


  mount_uploader :logo, LogoUploader
  mount_uploader :banner, BannerUploader
  mount_uploader :member_card, MemberCardUploader

  validates :name, :nick, :slogan, :phone, :email, presence: true
  validates_uniqueness_of :name
  # validates :longitude, :latitude, presence: true
  validates_format_of :phone, with: PHONE_REGEXP, message: '手机座机传呼机，6-12位号码'
  validates_format_of :email, with: MULTIPLE_EMAIL_REGEXP

  after_create :gen_token, :gen_invite_code

  TYPE = {
    0 => '订阅号',
    1 => '服务号'
  }

  searchable do
    text :name,       stored: true
    text :nick,       stored: true
    text :phone,      stored: true
    text :email,      stored: true
    text :address,    stored: true
  end

  # 是否支持高级接口
  def app_available?
    app_id.present? && app_secret.present?
  end

  def gen_token
    update_column :token, SecureRandom.hex(8) if self.token.blank?
  end

  def gen_invite_code
    update_column :invite_code, SecureRandom.hex(4)
  end

  def entry_url
    "#{ENV['WESELL_SERVER']}/wechat/#{name}"
  end


  def sent_orders customer=nil
    if customer.present?
      self.orders.sent.where(customer_id: customer.id)
    else
      self.orders.sent
    end
  end

  def sent_orders_amount customer
    amount = 0
    sent_orders(customer).each do |order|
      amount += order.amount
    end
    amount
  end

  def order_tips customer
    order_counter = customer.orders.active.count
    if order_counter <= 0
      '您没有正在处理的订单'
    else
      "您有#{order_counter}份订单正在处理"
    end
  end

  def classify_store store, kategory
    op = operations.where(store_id: store.id).first
    op.update_attribute :kategory_id, kategory.id
  end

  def menu_keys_options; WechatMenu::KEYS.invert.to_a + self.wechat_keys.pluck(:tips, :key) end

  def community?;  village.present?  end

  def default_village; self.villages.first end

  def csss #community service supervisors, dedicated to a specific village
    return User.where id: Ownership.where(target_type: "Village", target_id: self.villages.pluck(:id), role_identifier: "css").pluck(:user_id)
  end

  def ccas #community service supervisors, dedicated to a specific village
    return User.where id: Ownership.where(target_type: "Village", target_id: self.villages.pluck(:id), role_identifier: "cca").pluck(:user_id)
  end


end
