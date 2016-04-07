class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.text :description
      t.string :phone
      t.string :email
      t.string :street
      t.float :latitude
      t.float :longitude
      t.integer :creator_id
      t.integer :orders_count, default: 0

      t.timestamps
    end
  end
end
