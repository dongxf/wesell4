class AddOidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :oid, :string, default: '', null: false
  end
end
