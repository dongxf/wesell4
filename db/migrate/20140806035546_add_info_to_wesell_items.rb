class AddInfoToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :info, :text
  end
end
