class AddCommentsCountToWesellItems < ActiveRecord::Migration
  def up
    add_column :wesell_items, :comments_count, :integer, default: 0

    # WesellItem.find_each do |wi|
    #   wi.update comments_count: wi.comments.count
    # end
  end

  def down
    remove_column :wesell_items, :comments_count
  end
end
