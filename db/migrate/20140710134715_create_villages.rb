class CreateVillages < ActiveRecord::Migration
  def change
    create_table :villages do |t|
      t.integer :instance_id
      t.string  :name

      t.timestamps
    end

    add_index :villages, :instance_id
  end
end
