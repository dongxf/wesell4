class OrderOption < ActiveRecord::Base
  belongs_to :order
  belongs_to :order_config_option

  # delegate :monetary_tag, to: :order
  before_create :set_default

  def label store=nil
    store ||= order.store
    price == 0 ? name : "#{name} [+#{store.monetary_tag}#{price}]"
  end

  def set_default
    if order_config_option.present?
      self.name = order_config_option.name
      self.price = order_config_option.price
    end
  end
end
