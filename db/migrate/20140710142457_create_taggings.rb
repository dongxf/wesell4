class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :sub_tag_id
      t.integer :village_item_id

      t.timestamps
    end

    add_index :taggings, [:sub_tag_id, :village_item_id]
  end
end
