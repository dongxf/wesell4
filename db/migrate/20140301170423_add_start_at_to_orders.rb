class AddStartAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :start_at, :datetime
  end
end
