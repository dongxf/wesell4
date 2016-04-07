class OrderItemOption < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :wesell_item_option

  # delegate :monetary_tag, to: :order_item

  after_create :set_attrs

  def label store=nil
    store ||= order_item.wesell_item.store
    price == 0 ? name : "#{name} [+#{store.monetary_tag}#{price}]"
  end

  def set_attrs
    update_attributes name: wesell_item_option.name, price: wesell_item_option.price
  end
end
