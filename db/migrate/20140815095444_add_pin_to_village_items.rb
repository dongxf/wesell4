class AddPinToVillageItems < ActiveRecord::Migration
  def up
    add_column :village_items, :pin, :string

    VillageItem.find_each do |vi|
      vi.update_attribute(:pin, vi.gen_pin)
    end
  end

  def down
    remove_column :village_items, :pin
  end
end
