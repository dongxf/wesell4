class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :pic
      t.integer :post_id
      t.timestamps
    end
  end
end
