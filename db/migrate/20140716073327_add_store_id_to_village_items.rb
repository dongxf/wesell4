class AddStoreIdToVillageItems < ActiveRecord::Migration
  def change
  	remove_column :village_items, :link
  	add_column    :village_items, :store_id, :integer
  end
end
