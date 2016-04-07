class AddOldidToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :oldid, :integer
  end
end
