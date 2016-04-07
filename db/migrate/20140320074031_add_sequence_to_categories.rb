class AddSequenceToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :sequence, :integer, default: 100, null: false
    add_column :kategories, :sequence, :integer, default: 100, null: false
  end
end
