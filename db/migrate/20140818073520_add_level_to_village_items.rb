class AddLevelToVillageItems < ActiveRecord::Migration
  def up
    add_column :village_items, :level, :integer, default: 1
    VillageItem.find_each do |vi|
      vi.update_attribute(:level, 3) if vi.approved
      vi.update_attribute(:level, 0) if vi.disabled
    end
  end

  def down
    remove_column :village_items, :level, :integer, default: 1
  end
end
