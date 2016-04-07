class ChangeTableForWesellItemOptions < ActiveRecord::Migration
  def change
    remove_column :wesell_item_options, :default
    add_column    :wesell_item_options, :sequence, :integer, default: 10
  end
end
