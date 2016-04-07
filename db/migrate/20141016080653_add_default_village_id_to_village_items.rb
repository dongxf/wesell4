class AddDefaultVillageIdToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :default_village_id, :integer
  end
end
