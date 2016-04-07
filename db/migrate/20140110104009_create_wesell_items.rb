class CreateWesellItems < ActiveRecord::Migration
  def change
    create_table :wesell_items do |t|
      t.string :name
      t.text :description
      t.decimal :price,          :precision => 8, :scale => 2, default: 0
      t.decimal :original_price, :precision => 8, :scale => 2, default: 0
      t.string  :unit_name
      t.integer :quantity,   default: 0
      t.integer :total_sold, default: 0
      t.integer :status,     default: 0
      t.string :image

      t.integer :store_id
      t.integer :category_id
      t.string  :type

      t.timestamps
    end
  end
end
