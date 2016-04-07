class AddShippingChargeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :shipping_charge, :decimal, default: 0, :precision => 8, :scale => 2
    add_column :stores, :shipping_charge_option, :integer
  end
end
