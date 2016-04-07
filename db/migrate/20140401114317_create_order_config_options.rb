class CreateOrderConfigOptions < ActiveRecord::Migration
  def change
    create_table :order_config_options do |t|
      t.integer :order_config_id
      t.integer :store_id
      t.string :name
      t.decimal :price, default: 0, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
