class AddCidToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :cid, :string
  end
end
