class AddSceneidToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :sceneid, :integer
  end
end
