class RemoveOptionsSettingFromWesellItems < ActiveRecord::Migration
  def change
    remove_column :wesell_items, :options_setting, :integer
  end
end
