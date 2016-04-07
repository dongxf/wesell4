class AddSubscribedToCustomers < ActiveRecord::Migration
  def up
    add_column :customers, :subscribed, :boolean, default: true
    Customer.where(status: 2).update_all(subscribed: false)
  end

  def down
    remove_column :customers, :subscribed
  end
end
