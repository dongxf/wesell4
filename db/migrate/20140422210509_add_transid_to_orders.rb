class AddTransidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :transid, :string, default: '', null: false
  end
end
