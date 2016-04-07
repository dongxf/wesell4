class AddCustomerIdAndInstanceIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :customer_id, :integer
    add_column :members, :instance_id, :integer
    add_index  :members, [:customer_id, :instance_id], unique: true
  end
end
