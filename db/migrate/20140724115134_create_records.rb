class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
    	t.string :content
    	t.integer :customer_id
    	t.integer :instance_id
    	t.integer :result_count

      t.timestamps
    end

    add_index :records, [:customer_id]

  end
end
