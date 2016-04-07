class AddFavorCountToVillageItems < ActiveRecord::Migration
  def change
	add_column :village_items, :favor_count, :integer, default: 0
  end
end
