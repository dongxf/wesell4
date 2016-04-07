class AddOptionsGroupIdToWesellItemOptions < ActiveRecord::Migration
  def change
    add_column :wesell_item_options, :options_group_id, :integer
  end
end
