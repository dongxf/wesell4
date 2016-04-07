class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer  :customer_id
      t.integer  :village_item_id
      t.string   :content

      t.timestamps
    end

    add_index :comments, [:customer_id, :village_item_id]
  end
end
