class AddContactToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :address, :string
    add_column :orders, :contact, :string
    add_column :orders, :phone,   :string
    add_column :orders, :comment, :string
  end
end
