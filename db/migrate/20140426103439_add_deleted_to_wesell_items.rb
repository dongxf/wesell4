class AddDeletedToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :deleted, :boolean, default: false, null: false
    WesellItem.where('status = 11').update_all deleted: true, status: 10
  end
end
