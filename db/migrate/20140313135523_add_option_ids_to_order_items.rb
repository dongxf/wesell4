class AddOptionIdsToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :option_ids, :string
  end
end
