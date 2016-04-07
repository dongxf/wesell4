class AddShippingChargeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_charge, :decimal, default: 0, :precision => 8, :scale => 2
  end
end
