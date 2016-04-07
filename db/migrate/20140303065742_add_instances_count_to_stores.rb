class AddInstancesCountToStores < ActiveRecord::Migration
  def change
    add_column :stores, :instances_count, :integer, null: false, default: 0
  end
end
