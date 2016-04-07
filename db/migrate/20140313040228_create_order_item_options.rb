class CreateOrderItemOptions < ActiveRecord::Migration
  def change
    create_table :order_item_options do |t|
      t.integer :order_item_id
      t.integer :wesell_item_option_id
      t.string :name
      t.decimal :price, :precision => 8, :scale => 2, default: 0

      t.timestamps
    end
  end
end
