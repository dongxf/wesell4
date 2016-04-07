class CreateKategories < ActiveRecord::Migration
  def change
    create_table :kategories do |t|
      t.string  :name,         default: "", null: false
      t.integer :instance_id
      t.integer :stores_count, default: 0, null: false

      t.timestamps
    end
  end
end
