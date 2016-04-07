class CreateWesellItemOptions < ActiveRecord::Migration
  def change
    create_table :wesell_item_options do |t|
      t.integer :wesell_item_id
      t.string :name
      t.decimal :price, :precision => 8, :scale => 2, default: 0
      t.boolean :default

      t.timestamps
    end
  end
end
