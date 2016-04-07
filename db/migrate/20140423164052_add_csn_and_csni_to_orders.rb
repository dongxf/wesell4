class AddCsnAndCsniToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :csn, :integer, default: 0, null: false
    add_column :orders, :csni, :integer, default: 0, null: false
  end
end
