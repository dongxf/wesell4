class CreateExpresses < ActiveRecord::Migration
  def up
    create_table :expresses do |t|
      t.string :name
      t.string :addr
      t.text   :desc
      t.string :phone
      t.string :invite_code
      t.integer :creator_id

      t.timestamps
    end

    add_column :orders, :express_id, :integer
  end

  def down
    drop_table :expresses
    drop_column :orders, :express_id
  end
end
