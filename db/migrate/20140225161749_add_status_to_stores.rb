class AddStatusToStores < ActiveRecord::Migration
  def change
    add_column :stores, :open, :boolean, null: false, default: false
  end
end
