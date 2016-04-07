class AddLogoToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :logo, :string
  end
end
