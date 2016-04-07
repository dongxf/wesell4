class AddWesellItemsCountToStores < ActiveRecord::Migration
  def change
    add_column :stores, :wesell_items_count, :integer, null: false, default: 0
  end
end
