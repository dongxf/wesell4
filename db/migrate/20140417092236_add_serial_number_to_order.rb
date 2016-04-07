class AddSerialNumberToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :serial_number, :integer, default: 0, null: false

    Store.find_each do |store|
      store.orders.where("submit_at IS NOT NULL").order("submit_at asc").each_with_index do |order, index|
      	order.update_attribute(:serial_number, index+1)
      end
    end
  end

  def self.down
    remove_column :orders, :serial_number
  end
end
