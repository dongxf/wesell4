class CreateSubTags < ActiveRecord::Migration
  def change
    create_table :sub_tags do |t|
      t.integer :tag_id
      t.string  :name

      t.timestamps
    end

    add_index :sub_tags, :tag_id
  end
end
