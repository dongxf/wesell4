class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.integer :instance_id
      t.integer :status, default: 0
      t.string :openid
      t.string :name
      t.string :phone
      t.string :email
      t.integer :credit, default: 0
      t.integer :orders_count, default: 0

      t.timestamps
    end
  end
end
