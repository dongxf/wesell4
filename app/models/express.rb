class Express < ActiveRecord::Base
  include Bindable

  belongs_to :creator, class_name: 'User'
  has_many :orders
  has_many :express_stores, dependent: :destroy
  has_many :stores, through: :express_stores

  validates :name, :addr, :phone, presence: true
  validates_format_of :phone, with: PHONE_REGEXP, message: '手机座机传呼机，6-12位号码'

  before_create :gen_invite_code

  def gen_invite_code
    loop do
      token = SecureRandom.hex(4)
      break self.invite_code = token unless Express.exists?(invite_code: token)
    end
  end
end
