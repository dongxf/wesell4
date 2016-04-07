class AddCustomersCountToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :customers_count, :integer, default: 0, null: false
  end
end
