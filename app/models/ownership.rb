class Ownership < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true

  validates_uniqueness_of :user_id, scope: [:target_id, :target_type, :role_identifier]
  before_validation :email_to_user

  OWNERSHIP_TYPE = {
    owner: '店铺掌柜',
    employee: '店铺员工',
    css: '社区服务督导', #community service supervisor
    cca: '社区推广专员', #community coverage agent"
    cda: '社区配送专员', #community delivery agent"
  }
  symbolize :role_identifier, in: OWNERSHIP_TYPE.keys, scopes: :shallow, methods: true, default: :owner

  attr_accessor :email

  def email_to_user
    if email.present? && user_id.blank?
      @user = User.find_by email: self.email
      self.user_id = @user.id if @email.present?
      self.role_identifier = 'employee'
    end
  end
end
