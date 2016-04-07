class AddCommentersCountToVillageItems < ActiveRecord::Migration
  def up
    add_column :village_items, :commenters_count, :integer, default: 0

    VillageItem.find_each do |vi|
      vi.update commenters_count: vi.comments.group(:customer_id).length
    end
  end

  def down
    remove_column :village_items, :commenters_count
  end
end
