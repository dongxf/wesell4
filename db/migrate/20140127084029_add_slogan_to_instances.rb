class AddSloganToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :slogan, :string, null: false, default: ""
  end
end
