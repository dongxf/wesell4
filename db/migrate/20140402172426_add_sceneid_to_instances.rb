class AddSceneidToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :sceneid, :integer
  end
end
