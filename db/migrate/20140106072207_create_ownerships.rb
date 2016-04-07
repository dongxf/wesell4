class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.integer :user_id
      t.integer :target_id
      t.string  :target_type
      t.string  :role_identifier

      t.timestamps
    end
  end
end
