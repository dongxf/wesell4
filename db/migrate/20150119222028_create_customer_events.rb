class CreateCustomerEvents < ActiveRecord::Migration
  def change
    create_table :customer_events do |t|
      t.integer :customer_id
      t.integer :target_id
      t.string :target_type
      t.string :duration
      t.string :frequency
      t.string :event_type
      t.integer :event_count
      t.string :name
      t.string :url
      t.string :comment

      t.timestamps
    end
  end
end
