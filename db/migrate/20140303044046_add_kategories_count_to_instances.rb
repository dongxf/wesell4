class AddKategoriesCountToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :kategories_count, :integer, null: false, default: 0
  end
end
