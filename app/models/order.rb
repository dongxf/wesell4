require 'wechat_pay'
require 'alipay'

class Order < ActiveRecord::Base
  include AASM
  include Printable
  include OrderNotifier

  belongs_to :customer#, counter_cache: true
  belongs_to :instance#, counter_cache: true
  belongs_to :store   #, counter_cache: true
  belongs_to :express

  has_many :order_items, dependent: :destroy
  has_many :wesell_items, through: :order_items
  has_many :order_actions
  has_many :order_options, dependent: :destroy
  has_many :order_config_options, through: :order_options

  validates :contact, :phone, presence: true
  validates :address, presence: true, unless: :address_needless?
  validate :check_start_at, unless: :time_needless?
  # validates_length_of :address, :minimum => 5
  validates_length_of :contact, :minimum => 2
  validates_format_of :phone, :with => PHONE_REGEXP, message: '手机座机传呼机，6-12位号码'
  validates_numericality_of :items_count, greater_than_or_equal_to: 0

  default_scope { order('orders.submit_at DESC') }
  scope :valid,       -> { where('items_count > 0') }
  scope :active,      -> { where('status in (?)', ['sent', 'paid', 'require_payment', 'accepted', 'shipped'])}
  scope :unopen,      -> { where('status <> ?'  , 'open')}
  scope :history,     -> { where('status in (?)', ['received', 'confirmed'])}
  scope :unconfirmed, -> { where('status <> ?'  , 'confirmed')}
  scope :successful,  -> { where('status in (?)', ['sent', 'paid', 'accepted', 'shipped', 'received', 'confirmed'])}
  scope :hurriable, -> { where('status in (?)', ['sent', 'accepted', 'shipped' ] )}

  delegate :name, :monetary_unit, :monetary_tag, to: :store
  attr_accessor :message, :pay_info
  attr_accessor :start_date, :start_time_hour, :start_time_minute

  before_save   :set_start_at#, :log_status
  after_create  :gen_oid
  after_save :update_counter_cache
  after_destroy :update_counter_cache

  STATUSES = {
    open:             '未下单',
    sent:             '已提交',
    canceled:         '已撤销',           # 买家取消订单
    rejected:         '卖家已拒绝此订单',   # 店家拒绝此单
    require_payment:  '等待买家付款',      # 买家选择先付款时，使用此状态
    paid:             '买家已付款',
    accepted:         '卖家接受此订单',     # 店家正在处理订单时，将订单设为此状态
    reposted:         '卖家已转发配送',
    shipped:          '卖家已发货',        # 店家发货后，将订单设为此状态，如外卖
    received:         '买家已收货',        # 买家收货后，店家将订单设为received
    confirmed:        '买家确认订单',       # 买家确认订单完成，评论
    finished:         '订单完成',           # 店家确认完成订单
    event_open:       '尚未下单',
    event_sent:       '等待确认中',
    event_canceled:   '订单已取消',
    event_rejected:   '报名未成功 :(',
    event_require_payment:  '等待付款中',
    event_paid:       '付款已成功',
    event_accepted:   '报名已成功',
    event_reposted:   '报名处理中',
    event_shipped:    '报名已成功',        # 店家发货后，将订单设为此状态，如外卖
    event_confirmed:  '报名已成功',
    event_finished:   '报名已成功'
  }

  aasm column: 'status' do
    state :open, initial: true
    state :sent, after_commit: [:new_order_notify, :cal_quantity]
    state :reposted, after_commit: [:repost_order_notify]
    state :canceled, after_commit: [:order_canceled]
    state :rejected, after_commit: [:order_rejected]
    state :require_payment
    state :paid, after_commit: [:new_order_notify, :update_payment_status, :cal_quantity]
    state :accepted, after_commit: [:order_accepted]
    state :shipped, after_commit: [:order_shipped, :ship_wechat_notify]
    state :received
    state :confirmed
    state :finished, after_commit: [:update_payment_status]

    event :submit do
      transitions from: [:open, :require_payment], to: :sent,
                  guards: [:check_user_status, :check_open_status, :check_offline, :check_quantity, :check_min_charge, :check_customer]
    end

    event :waiting_payment do
      transitions from: :open, to: :require_payment,
                  guards: [:check_open_status, :check_offline, :check_quantity, :check_min_charge, :check_customer]
    end

    event :paid do
      transitions from: [:open, :require_payment, :sent, :accepted, :shipped, :received], to: :paid
    end

    event :reject do
      transitions from: [:sent, :paid, :accepted], to: :rejected
    end

    event :cancel do
      transitions from: :open, to: :canceled
    end

    event :accept do
      transitions from: [:sent, :rejected, :require_payment, :paid], to: :accepted
    end

    event :repost do
      transitions from: [:sent, :require_payment, :paid, :accepted], to: :reposted
    end

    event :ship do
      transitions from: [:reposted, :sent, :rejected, :paid, :accepted], to: :shipped
    end

    event :receive do
      transitions from: [:reposted, :sent, :accepted, :paid, :shipped], to: :received
    end

    event :confirm do
      transitions from: [:reposted, :sent, :accepted, :paid, :shipped, :received], to: :confirmed
    end

    event :finish do
      transitions from: [:reposted, :sent, :accepted, :paid, :shipped, :received, :confirmed], to: :finished
    end
  end

  PAYMENT_STATUSES = {
    paid: '已付款',
    unpaid: '未付款'
  }
  symbolize :payment_status, in: PAYMENT_STATUSES.keys, scopes: :shallow, methods: true, default: :unpaid

  searchable do
    text :address, stored: true
    text :contact, stored: true
    text :phone,   stored: true
    text :comment, stored: true
    text :store_name do
      store.name
    end
    text :instance_name do
      instance.name
    end
    string :status
  end

  StoreConfig::PAYMENT_OPTIONS.each do |key|
    define_method "#{key}_pay?" do
      payment_option == key
    end
  end

  def self.init_order instance, store, customer=nil
    raise 'Store is blank'    if store.blank?
    raise 'Instance is blank' if instance.blank?
    if customer.present?
      order = Order.find_or_create_by store_id: store.id, instance_id: instance.id, customer_id: customer.id, status: 'open'
      last_order = customer.orders.unopen.where(store_id: store.id).first
      last_order ||= customer.orders.unopen.first
      if last_order.present?
        order.contact = last_order.contact
        order.phone   = last_order.phone
        order.address = last_order.address if store.address?
        order.save(validate: false) if order.changed?
      end
    else
      order = Order.create store_id: store.id, instance_id: instance.id, status: 'open'
    end
    order
  end

  def human_status
    ss = "#{self.store.stype == 'event' ? 'event_' : ''}" + self.status 
    STATUSES[ss.to_sym]
  end

  def human_payment_option
    StoreConfig::HUMAN_PAYMENT_OPTIONS[self.payment_option]
  end

  def human_payment_status
    PAYMENT_STATUSES[payment_status]
  end

  def calculate_amount
    _shipping_charge = calculate_shipping_charge
    _options_charge  = calculate_options
    _amount = total_price + _shipping_charge + _options_charge
    self.update_columns amount: _amount, shipping_charge: _shipping_charge
    Order.reset_counters self.id, :order_items
    return _amount
  end

  def calculate_options
    price = 0
    order_options.each do |option|
      price += option.price
    end
    price
  end

  def total_price
    _total = 0
    order_items.each do |item|
      _total += item.total_price
    end
    return _total
  end

  def total_fee
    (amount*100).to_i
  end

  def order_item product, quantity
    item = self.order_items.find_or_initialize_by(wesell_item_id: product.id)
    item.quantity += quantity
    item.quantity > 0 ? item.save : item.destroy
    item
  end

  def order_item2 product, quantity
    item = self.order_items.find_or_initialize_by(wesell_item_id: product.id)
    item.quantity = quantity
    item.quantity > 0 ? item.save : item.destroy
    item
  end

  def order_item_with_options product, quantity, option_ids
    option_ids.reject! { |i| i.empty? }
    item = self.order_items.find_or_initialize_by(wesell_item_id: product.id, option_ids: option_ids.join(','))
    item.quantity += quantity
    item.quantity > 0 ? item.save : item.destroy
    item.set_options option_ids unless item.destroyed?
    item
  end

  def items_in_category category
    self.wesell_items.where('wesell_items.category_id = ?', category.id)
  end

  def addon_hints
    str = '请在此备注留言'
    return str if self.store.stype == 'normal'
    str = ''
    self.wesell_items.each do |wi|
      str += "#{wi.addon_hints}\n" if !wi.addon_hints.blank?
    end
    str = '请在此留言备注' if str.blank?
    return str
  end



  def items_category
    h = {}
    order_items.each do |item|
      if h[item.category_id]
        if h[item.category_id][item.wesell_item_id]
          _quantity = h[item.category_id][item.wesell_item_id]
          h[item.category_id].merge!(item.wesell_item_id => (item.quantity + _quantity))
        else
          h[item.category_id].merge!(item.wesell_item_id => item.quantity)
        end
      else
        h[item.category_id] = {item.wesell_item_id => item.quantity}
      end
    end
    h
  end

  def category_count category
    ic = items_category
    cs = ic[category.id]
    cs ? cs.size : 0
  end

  def product_count wesell_item
    ic = items_category
    category_id = wesell_item.category_id
    ic[category_id].present? ? (ic[category_id][wesell_item.id] || 0) : 0
  end

  def categories_counter
    h = {}
    order_items.each do |item|
      h[item.category_id] ||= 0
      h[item.category_id] += 1
    end
    h
  end

  def subject
    "订单号 #{self.id} \n"
  end

  def payment_subject
    "#{instance_id}-#{store_id}-#{id}"
  end

  # todo
  def hurry_up!
    log_action :hurry_up
    urge_order
    OrderMailer.delay.hurry_up(self)
  end

  def hurry_up_times
    order_actions.hurry_up.size
  end

  def hurry_feedback
    server_url=ENV['WESELL_SERVER']
    order_link = "订单<a href='#{server_url}/westore/orders/#{self.id}?customer_cid=#{self.customer.cid}&instance_id=#{self.instance.id}'>[#{self.id}]</a>"
    return "#{order_link}等候处理中" if sent?
    return "#{order_link}玩命处理中" if accepted?
    return "#{order_link}玩命配送中" if shipped?
    return "#{order_link}玩命催促中"
  end

  def hurriable?
    return false unless sent? || accepted? || shipped?
    return false if hurry_up_times >= 3
    return true  if order_actions.hurry_up.blank?
    return 10.minutes.ago > order_actions.hurry_up.last.created_at
  end

  def calculate_shipping_charge
    return 0 if total_price == 0
    if store.shipping_charge > 0
      case store.shipping_charge_option
      when 1 #'低于最低消费收取运费'
        shipping_charge = (total_price < store.min_charge ? store.shipping_charge : 0)
      else
        shipping_charge = store.shipping_charge
      end
    else
      shipping_charge = 0
    end
    return shipping_charge
  end

  def shipping_charge_tips
    return nil if items_count == 0
    case store.shipping_charge_option
    when nil
      "每单收取运费#{store.shipping_charge}#{monetary_unit}" if store.shipping_charge > 0
    when 1
      "本店最低消费：#{store.min_charge}#{monetary_unit}，低于最低消费收取运费#{store.shipping_charge}#{monetary_unit}"
    when 2
      "每单收取运费#{store.shipping_charge}#{monetary_unit}"
    end
  end

  # serial_number          店铺的订单流水号
  # serial_number_instance 公众号（包含公众号所有运营店铺）的订单流水号
  # csn 顾客在店铺的订单次数
  # csni 顾客在平台的订单次数
  def new_order_notify
    update_columns submit_at:              Time.zone.now,
                   serial_number:          self.store.orders.successful.count,
                   serial_number_instance: self.instance.orders.successful.count,
                   csn:                    self.customer.orders.successful.where(store_id: self.store_id).count,
                   csni:                   self.customer.orders.successful.count

    print!
    order_submit
    OrderMailer.delay.new_order(self)
  end

  def repost_order_notify
    repost_order
  end

  def log_action(action)
    OrderAction.log self, action
  end

  def log_status
    log_action(status) if self.changed.include?('status')
  end

  def digest
    text = ''
    text << store.name
    unless self.open?
      text << " " + self.contact
      text << " " + self.phone
      text << " " + self.address if store.address?
    end
    return text
  end

  def status_digest
    text = ''
    text << store.name
    text << " " + self.human_amount
    text << " " + self.human_status
    return text
  end

  def human_amount
    "#{store.monetary_tag}#{amount}"
  end

  def start_date
    return @start_date if @start_date
    start_at.strftime('%Y-%m-%d') if start_at.present?
  end

  def start_time_hour
    return @start_time_hour if @start_time_hour
    start_at.strftime('%I') if start_at.present?
  end

  def start_time_minute
    return @start_time_minute if @start_time_minute
    start_at.strftime('%M') if start_at.present?
  end

  def set_start_at
    if self.start_date.present? && self.start_time_hour.present? && self.start_time_hour.present?
      self.start_at = Time.zone.parse("#{self.start_date} #{self.start_time_hour}:#{self.start_time_minute} +08:00")
    end
  end

  def check_start_at
    case
    when start_date.blank?
      errors.add(:start_date, "请选择预约日期")
    when start_time_hour.blank?
      errors.add(:start_time_hour, "请选择预约时间")
    when start_time_minute.blank?
      errors.add(:start_time_hour, "请选择预约时间")
    end
  end

  def address_needless?
    self.store.noaddress?
  end

  def time_needless?
    self.store.nodate?
  end

  def human_order_time
    if self.submit_at.present?
      I18n.localize self.submit_at, format: :long
    else
      self.open? ? '未下单' : '已下单'
    end
  end

  def confirmable?
    received? || accepted? || shipped?
  end

  def update_payment_status
    update_attribute :payment_status, :paid
  end

  def paid_by? str
    payment_option == str
  end

  def gen_oid
    if oid.blank?
      begin
        o_id = SecureRandom.hex(16)
      end while Order.exists?(oid: o_id)
      self.update_attribute :oid, o_id
    end
  end

  def editable?
    ["open", "require_payment"].include? status
  end

  def timestamp
    updated_at.to_i
  end

  def shipped_at
    order_actions.shipped.first.created_at if order_actions.shipped.present?
  end

  def update_counter_cache
    if self.store.present?
      self.store.orders_count = Order.where("status <> ? AND store_id = ?", 'open', self.store_id).count
      self.store.save
    end
    if self.instance.present?
      self.instance.orders_count = Order.where("status <> ? AND instance_id = ?", 'open', self.instance_id).count
      self.instance.save
    end
    if self.customer.present?
      self.customer.orders_count = Order.where("status <> ? AND customer_id = ?", 'open', self.customer_id).count
      self.customer.save
    end
  end

  #todo: coupon
  def real_pay
    amount
  end

protected

  def check_user_status
    return true  if self.instance.creator.nil?
    if self.instance.creator.status == 'expired'
      self.message = "因故无法接受您的订单，请致电店家电话#{store.phone}"
      return false
    end
    true
  end

  def check_quantity
    order_items.each do |item|
      wesell_item = item.wesell_item
      if wesell_item.rule == 'showroom' && wesell_item.showroom_id
        sr = Showroom.find wesell_item.showroom_id
        customer = item.order.customer
        if customer.openid.nil?
          mpn = wesell_item.store.instances.first.nick #very buggy
          mpn ||= '幸福大院'
          self.message = "欢聚体验：#{sr.name}仅限会员购买，请关注微信公众帐号‘#{mpn}’后购买"
          logger.info self.message
          return false
        end
        mq = sr.max_quantity
        pd = customer.showroom_purchased_item_count(sr)
        if pd + item.quantity > mq
          self.message = "欢聚体验：#{sr.name}您还可预约#{mq-pd}#{item.unit_name}，感谢您将更多机会推荐或留给新朋友"
          self.message = "欢聚体验：您已达到#{sr.name}的设定预约上限，感谢您将体验机会优先推荐给新朋友" if pd >= mq
          logger.info self.message
          return false
        end
      end

      if wesell_item.status == 0 # 不限量供应
        true
      elsif wesell_item.quantity < item.quantity
        self.message = "库存不足: #{item.name}仅剩#{item.wesell_item.quantity}份"
        logger.info self.message
        return false
      end
    end
    true
  end

  #######  how about when go to payment, in the meantime quantity get 0
  def cal_quantity
    order_items.each do |item|
      wesell_item = item.wesell_item
      if wesell_item.status == 0 # 不限量供应
        wesell_item.total_sold += item.quantity
        wesell_item.save
      elsif wesell_item.quantity < item.quantity
        self.message = "库存不足: #{wesell_item.name}仅剩#{wesell_item.quantity}份"
        logger.info self.message
      else
        wesell_item.quantity -= item.quantity
        wesell_item.total_sold += item.quantity
        wesell_item.save
      end
    end
  end

  def check_offline
    wesell_items.each do |wesell_item|
      if wesell_item.offline?
        self.message = "抱歉，#{wesell_item.name}已经下架，请删除后重新下单。"
        logger.info self.message
        return false
      end
    end
    true
  end

  def check_min_charge
    return true if self.store.min_charge == 0
    return true if amount >= self.store.min_charge
    case store.shipping_charge_option
    when 0, 2 #'低于最低消费禁止下单'
      self.message = "本店最低消费：#{store.min_charge}#{monetary_unit}"
      logger.info self.message
      false
    else
      true
    end
  end

  def check_open_status
    return true if self.store.order_offline? && self.store.open?
    return true if self.store.is_open?
    self.message = "亲，您来晚了，小店已经打烊~"
    logger.info self.message
    return false
  end

  def check_customer
    return true if self.customer.normal?
    self.message = "很抱歉，您的订单无法提交!"
    logger.info self.message
    return false
  end

  def ship_wechat_notify
    if self.paid_by?('wechat')
      # 微信支付发货接口
      wechat_pay = WechatPay::Util.new self
      wechat_pay.ship!
    end
  end
end
