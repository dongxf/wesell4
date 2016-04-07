class AddOptionsSettingToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :options_setting, :integer, default: 0, null: false
  end
end
