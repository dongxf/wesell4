class CreateLicenseUsers < ActiveRecord::Migration
  def change
    create_table :license_users do |t|
      t.integer :user_id
      t.integer :license_id

      t.timestamps
    end
  end
end
