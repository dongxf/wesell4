class AddLongitudeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :longitude, :float
    add_column :instances, :latitude, :float
  end
end
