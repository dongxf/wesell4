class ChangeCommentAsPolymorphic < ActiveRecord::Migration
  def up
    add_column :comments, :commentable_type, :string
    rename_column :comments, :village_item_id, :commentable_id
    Comment.find_each do |comment|
      comment.commentable_type = "VillageItem"
      comment.save
    end
  end

  def down
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :village_item_id
  end
end
