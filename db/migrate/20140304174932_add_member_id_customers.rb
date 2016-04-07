class AddMemberIdCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :member_id, :integer
    add_index :customers, [:member_id, :instance_id]
  end
end
