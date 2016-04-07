class CreateOrderConfigs < ActiveRecord::Migration
  def change
    create_table :order_configs do |t|
      t.integer :store_id
      t.string :name
      t.integer :style, default: 0, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
