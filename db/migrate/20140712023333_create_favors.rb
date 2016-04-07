class CreateFavors < ActiveRecord::Migration
  def change
    create_table :favors do |t|
      t.integer   :customer_id
      t.integer   :village_item_id

      t.timestamps
    end

    add_index :favors, [:customer_id, :village_item_id]
  end
end
