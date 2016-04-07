class AddIndexForOrders < ActiveRecord::Migration
  def change
    add_index :orders, :instance_id
    add_index :orders, :store_id
    add_index :orders, :customer_id
  end
end
