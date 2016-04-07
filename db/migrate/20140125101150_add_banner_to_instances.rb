class AddBannerToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :banner, :string
    add_column :stores, :banner, :string
  end
end
