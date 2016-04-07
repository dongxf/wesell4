class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :name
      t.string :nick
      t.text   :description
      t.string :phone
      t.string :email
      t.string :app_id
      t.string :app_secret
      t.string :token
      t.integer :creator_id
      t.integer :stores_count, default: 0
      t.integer :orders_count, default: 0

      t.timestamps
    end
  end
end
