module Ownable
  extend ActiveSupport::Concern

  included do
    has_many :ownerships,  as: :target
    has_many :owner_ownerships, -> { where('ownerships.role_identifier = ?', 'owner') }, as: :target, class_name: 'Ownership'
    has_many :employee_ownerships, -> { where('ownerships.role_identifier = ?', 'employee') }, as: :target, class_name: 'Ownership'

    has_many :managers, through: :owner_ownerships, class_name: 'User', source: 'user'
    has_many :employees, through: :employee_ownerships, class_name: 'User', source: 'user'
    has_many :users, through: :ownerships, class_name: 'User', source: 'user'
  end

  def add_manager user
    unless self.managers.include? user
      ownership = Ownership.find_or_initialize_by user_id: user.id, target_id: self.id, target_type: self.class.name
      ownership.update_attribute :role_identifier, :owner
    end
  end

  def add_employee user
    unless self.employees.include? user
      ownership = Ownership.find_or_initialize_by user_id: user.id, target_id: self.id, target_type: self.class.name
      ownership.update_attribute :role_identifier, :employee
    end
  end
end