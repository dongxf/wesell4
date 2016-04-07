class AddOptionsGroupsCountToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :options_groups_count, :integer, default: 0, null: false
  end
end
