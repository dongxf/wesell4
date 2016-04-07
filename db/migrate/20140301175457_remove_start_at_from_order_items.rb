class RemoveStartAtFromOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :start_at
  end
end
