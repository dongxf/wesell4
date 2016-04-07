class AddItemsCountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :items_count, :integer, default: 0
  end
end
