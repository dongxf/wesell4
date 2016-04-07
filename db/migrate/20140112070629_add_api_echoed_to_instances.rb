class AddApiEchoedToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :api_echoed, :integer, default: 0
  end
end
