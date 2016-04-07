class AddSerialNumberInstanceToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :serial_number_instance, :integer, default: 0, null: false
    Instance.find_each do |instance|
      instance.orders.unopen.reorder('submit_at ASC').each_with_index do |order, index|
        order.update_attribute(:serial_number_instance, index+1)
      end
    end
  end

  def down
    remove_column :orders, :serial_number_instance
  end
end
