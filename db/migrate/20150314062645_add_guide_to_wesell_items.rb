class AddGuideToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :guide, :text
  end
end