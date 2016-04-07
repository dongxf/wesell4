class CreateBinders < ActiveRecord::Migration
  def change
    create_table :binders do |t|
      t.integer :target_id
      t.string :target_type
      t.integer :customer_id

      t.timestamps
    end
    # add_index :binders, [:target_type, :target_id], unique: true, name: 'by_targets'
  end
end
