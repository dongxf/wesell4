class AddPageToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :page, :text
  end
end
