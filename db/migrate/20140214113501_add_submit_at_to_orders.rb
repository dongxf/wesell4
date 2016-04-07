class AddSubmitAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :submit_at, :datetime
  end
end
