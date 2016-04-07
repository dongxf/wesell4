class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.text :info
      t.string :title
      t.datetime :begin_at
      t.integer  :duration
      t.integer  :village_item_id

      t.timestamps
    end

    add_index :offers, [:village_item_id]
  end
end
