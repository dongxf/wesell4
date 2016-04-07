class RemoveStoreTypeFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :store_type
  end
end
