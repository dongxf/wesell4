class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :name
      t.integer :max_instance, default: 0
      t.integer :max_store,    default: 0
      t.integer :max_order,    default: 0
      t.decimal :price,        precision: 8, scale: 2, default: 0
      t.integer :users_count,  default: 0

      t.timestamps
    end
  end
end
