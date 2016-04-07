class AddShowCinfoToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :show_cinfo, :boolean, default: false
  end
end
