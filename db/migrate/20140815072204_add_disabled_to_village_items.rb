class AddDisabledToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :disabled, :boolean, default: false
    add_column :village_items, :disabled_reason, :text
  end
end
