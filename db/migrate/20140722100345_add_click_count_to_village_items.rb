class AddClickCountToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :click_count, :integer, default: 0
  end
end
