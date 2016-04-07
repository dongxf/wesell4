class AddActivatedToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :activated, :boolean, null: false, default: true
  end
end
