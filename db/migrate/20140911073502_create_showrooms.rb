class CreateShowrooms < ActiveRecord::Migration
  def change
    create_table :showrooms do |t|
      t.string :name
      t.integer :westore_id
      t.integer :max_quantity, default: 1

      t.timestamps
    end
  end
end
