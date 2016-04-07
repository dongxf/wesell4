class AddFromSceneidToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :from_sceneid, :integer, default: 0, null: false
  end
end
