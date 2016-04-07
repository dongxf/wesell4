class AddVscoreToVillageItems < ActiveRecord::Migration
  def self.up
  	add_column :village_items, :vscore, :integer, null: false, default: 0

    VillageItem.find_each do |vi|
    	vi.update_attribute(:vscore, vi.weight)
    end
  end

  def self.down
  	remove_column :village_items, :vscore
  end
end
