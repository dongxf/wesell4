class AddMetaToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :meta, :string
  end
end
