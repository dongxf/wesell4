class CreatePearls < ActiveRecord::Migration
  def change
    create_table :pearls do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :tutor

      t.timestamps
    end
  end
end
