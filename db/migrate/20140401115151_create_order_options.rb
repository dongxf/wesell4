class CreateOrderOptions < ActiveRecord::Migration
  def change
    create_table :order_options do |t|
      t.integer :order_id
      t.integer :order_config_option_id
      t.string :name
      t.decimal :price, default: 0, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
