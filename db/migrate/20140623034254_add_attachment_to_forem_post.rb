class AddAttachmentToForemPost < ActiveRecord::Migration
  def change
  	add_column :forem_posts, :attachment, :string
  end
end
