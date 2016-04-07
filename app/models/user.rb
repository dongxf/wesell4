class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :license_users
  has_many :licenses, through: :license_users

  has_many :created_instances, class_name: 'Instance', foreign_key: 'creator_id'
  has_many :created_stores, class_name: 'Store', foreign_key: 'creator_id'

  has_many :ownerships, dependent: :destroy
  has_many :owner_ownerships, -> {where('ownerships.role_identifier = ?', 'owner')}, class_name: 'Ownership'
  has_many :employee_ownerships, -> {where('ownerships.role_identifier = ?', 'employee')}, class_name: 'Ownership'

  # 自营公众号，有owner权限，或者employee权限
  has_many :instances, through: :ownerships, source: :target, source_type: 'Instance'
  has_many :owner_instances, through: :owner_ownerships, source: :target, source_type: 'Instance'
  has_many :employee_instances, through: :employee_ownerships, source: :target, source_type: 'Instance'

  # 自营店铺，有owner权限，或者employee权限
  has_many :stores, through: :ownerships, source: :target, source_type: 'Store'
  has_many :owner_stores, through: :owner_ownerships, source: :target, source_type: 'Store'
  has_many :village_items, through: :ownerships, source: :target, source_type: 'VillageItem'
  has_many :owner_village_items, through: :owner_ownerships, source: :target, source_type: 'VillageItem'
  has_many :employee_stores, through: :employee_ownerships, source: :target, source_type: 'Store'

  # 加盟店铺
  has_many :operated_stores, class_name: 'Store', through: :instances, source: 'stores'
  # 加盟公众号
  has_many :operated_instances, class_name: 'Instance', through: :stores, source: 'instances'

  has_many :instance_operations, class_name: 'Operation', through: :instances, source: 'operations'
  has_many :store_operations, class_name: 'Operation', through: :stores, source: 'operations'

  has_many :instance_orders, class_name: 'Order', through: :instances, source: 'orders'
  has_many :store_orders, class_name: 'Order', through: :stores, source: 'orders'

  has_many :expresses, foreign_key: 'creator_id'

  has_many :printers, through: :stores
  has_many :customers, through: :instances
  has_many :villages, through: :instances
  has_many :replies, dependent: :destroy

  validates :name, :email, presence: true
  validates_format_of :email, with: email_regexp

  # after_create :load_default

  ROLE_TYPE = {
    admin: '系统大神',
    operator: '运营商',
    store_manager: '店铺经理',
    bizop: '客户服务',
    plain: '平台用户',
    vusr: '商圈用户'
  }
  symbolize :role_identifier, in: ROLE_TYPE.keys, scopes: :shallow, methods: true, default: :plain

  searchable do
    text :name,  stored: true
    text :email, stored: true
  end

  def available_instances
    # case self.role
    # when :admin
    #   Instance.all
    # end
  end

  def is_vusr?
    self.role_identifier == :vusr ? true : false
  end

  def load_default

    instance = self.instances.create(name: SecureRandom.hex(8), nick: '示例公众号', slogan: '用心服务美好生活', phone: '02022222222', email: email)
    s1 = instance.stores.create(name: '示例商店', description: '放心美味准时送达', phone: '02022222222', email: email, monetary_unit: '元', opening_hours: '09:00~21:00', open: true, street: '广州市天河区珠江新城高德置地广场A座12楼', creator_id: self.id)
    self.stores << s1

    c1 = s1.categories.create(name: '营养套餐')
    c2 = s1.categories.create(name: '单锅小炒')
    c3 = s1.categories.create(name: '经济快餐')

    p1 = c1.wesell_items.create(name: '卤肉饭套餐', price: 28, unit_name: '份', quantity: 100, status: 0)
    p2 = c1.wesell_items.create(name: '鱼香肉丝餐', price: 28, unit_name: '份', quantity: 100, status: 0)
    p3 = c1.wesell_items.create(name: '木须肉套餐', price: 28, unit_name: '份', quantity: 100, status: 0)

    s1.wesell_items << p1
    s1.wesell_items << p2
    s1.wesell_items << p3

    p1 = c2.wesell_items.create(name: '台湾卤肉饭', price: 28, unit_name: '份', quantity: 100, status: 0)
    p2 = c2.wesell_items.create(name: '鱼香肉丝饭', price: 28, unit_name: '份', quantity: 100, status: 0)
    p3 = c2.wesell_items.create(name: '木须炒肉饭', price: 28, unit_name: '份', quantity: 100, status: 0)

    s1.wesell_items << p1
    s1.wesell_items << p2
    s1.wesell_items << p3

  end

  def forem_name
    name
  end

  def forem_email
    email
  end

  def license
    if license_users.present?
      license_users.first.license
    end
  end

  def license_name
    license ? license.name : '测试试用'
  end

  def add_license licen
    licenses << licen unless licen == license
  end
end
