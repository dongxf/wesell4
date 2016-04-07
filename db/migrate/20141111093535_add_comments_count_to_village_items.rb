class AddCommentsCountToVillageItems < ActiveRecord::Migration
  def up
    add_column :village_items, :comments_count, :integer, default: 0

    VillageItem.find_each do |vi|
      vi.update comments_count: vi.comments.count
    end
  end

  def down
    remove_column :village_items, :comments_count
  end
end
