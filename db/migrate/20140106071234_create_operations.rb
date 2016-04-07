class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.integer :instance_id
      t.integer :store_id

      t.timestamps
    end
  end
end
