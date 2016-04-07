class CreateUserVillageItems < ActiveRecord::Migration
  def change
    create_table :user_village_items do |t|
      t.integer :user_id
      t.integer :village_item_id

      t.timestamps
    end
  end
end
