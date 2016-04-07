class AddDeletedToStores < ActiveRecord::Migration
  def change
    add_column :stores, :deleted, :boolean, null: false, default: false
  end
end
