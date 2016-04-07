class RemoveActiveFromStores < ActiveRecord::Migration
  def change
    remove_column :stores, :active, :boolean
    remove_column :stores, :open_at, :integer
    remove_column :stores, :close_at, :integer
  end
end
