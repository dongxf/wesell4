class AddActiveToStores < ActiveRecord::Migration
  def change
    add_column :stores, :active, :boolean, null: false, default: true
    add_column :stores, :open_at, :integer, null: false, default: 9
    add_column :stores, :close_at, :integer, null: false, default: 21
  end
end
