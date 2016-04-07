class AddUrlToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :url, :string, null: false, default: ''
  end
end
