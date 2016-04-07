class AddCheckLocationToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :check_location, :boolean, null: false, default: false
  end
end
