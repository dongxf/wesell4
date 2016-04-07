class CreateOptionsGroups < ActiveRecord::Migration
  def change
    create_table :options_groups do |t|
      t.integer :wesell_item_id
      t.integer :style

      t.timestamps
    end
  end
end
