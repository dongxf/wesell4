class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :wesell_item_id
      t.integer :category_id
      t.decimal :unit_price, precision: 8, scale: 2, default: 0.0
      t.string  :unit_name
      t.string  :name
      t.integer :quantity,   default: 0
      t.datetime :start_at
      t.string  :comment

      t.timestamps
    end
  end
end
