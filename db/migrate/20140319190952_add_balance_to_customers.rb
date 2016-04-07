class AddBalanceToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :balance, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
