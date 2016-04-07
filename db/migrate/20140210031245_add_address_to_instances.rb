class AddAddressToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :address, :string, default: ""
  end
end
