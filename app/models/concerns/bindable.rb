module Bindable
  extend ActiveSupport::Concern

  included do
    has_many :binders,  as: :target
    has_many :binderers, class_name: 'Customer', through: :binders, source: 'customer'
  end

  def bind_customer customer
    Binder.find_or_create_by customer_id: customer.id, target_id: self.id, target_type: self.class.name
  end

  def unbind_customer customer
    binder = Binder.find_by customer_id: customer.id, target_id: self.id, target_type: self.class.name
    binder.destroy if binder.present?
  end
end