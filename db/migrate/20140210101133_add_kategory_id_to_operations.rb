class AddKategoryIdToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :kategory_id, :integer
    remove_column :stores, :kategory_id
  end
end
