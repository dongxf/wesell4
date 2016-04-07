class RemoveColumnsVillageItems < ActiveRecord::Migration
  def up
    remove_column :village_items, :disabled
    remove_column :village_items, :approved
  end

  def down
    add_column :village_items, :disabled, :boolean
    add_column :village_items, :approved, :boolean
  end
end
