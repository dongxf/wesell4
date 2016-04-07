class AddMinChargeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :min_charge, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
