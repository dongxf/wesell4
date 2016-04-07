class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :store_id
      t.integer :instance_id
      t.integer :customer_id
      t.decimal :amount, default: 0, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
