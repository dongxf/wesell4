class AddPaymentsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_option, :string, null: false, default: ''
    add_column :orders, :payment_status, :string, null: false, default: ''
  end
end
