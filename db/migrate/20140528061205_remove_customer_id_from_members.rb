class RemoveCustomerIdFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :customer_id
    remove_index :members, [:customer_id, :instance_id]
    add_index :members, :instance_id
  end
end
