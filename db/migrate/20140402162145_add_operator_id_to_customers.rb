class AddOperatorIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :operator_id, :integer
  end
end
