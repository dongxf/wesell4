class AddSceneidToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :sceneid, :integer
  end
end
