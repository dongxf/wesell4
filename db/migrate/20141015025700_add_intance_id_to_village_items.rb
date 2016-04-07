class AddIntanceIdToVillageItems < ActiveRecord::Migration
  def up
    add_column :village_items, :instance_id, :integer

    VillageItem.find_each do |vi|
      vi.instance_id = Village.find(vi.village_id).instance.id
      vi.save
    end
  end

  def down
    remove_column :village_items, :instance_id
  end
end
