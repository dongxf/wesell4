class AddRemarkToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :remark, :string
  end
end
