class AddKategoryIdToStores < ActiveRecord::Migration
  def change
    add_column :stores, :kategory_id, :integer
  end
end
