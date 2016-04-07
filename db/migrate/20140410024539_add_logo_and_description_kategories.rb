class AddLogoAndDescriptionKategories < ActiveRecord::Migration
  def change
  	add_column :kategories, :logo, :string
  	add_column :kategories, :description, :string
  end
end
