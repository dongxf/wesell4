class AddActionerTypeAndactionerIdToOrderActions < ActiveRecord::Migration
  def change
    add_column :order_actions, :actioner_type, :string
    add_column :order_actions, :actioner_id,   :integer
  end
end
