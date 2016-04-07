class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :customer_id
      t.float :longitude, null: false, default: 0.0
      t.float :latitude,  null: false, default: 0.0
      t.string :address

      t.timestamps
    end
  end
end
