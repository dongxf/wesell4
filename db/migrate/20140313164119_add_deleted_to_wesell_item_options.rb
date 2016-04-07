class AddDeletedToWesellItemOptions < ActiveRecord::Migration
  def change
    add_column :wesell_item_options, :deleted, :boolean, null: false, default: false
  end
end
