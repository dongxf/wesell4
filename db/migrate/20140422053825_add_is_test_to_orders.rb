class AddIsTestToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :is_test, :boolean, default: false
  end
end
