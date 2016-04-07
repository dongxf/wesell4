class AddCategoriesCountToStores < ActiveRecord::Migration
  def change
    add_column :stores, :categories_count, :integer, null: false, default: 0
  end
end
