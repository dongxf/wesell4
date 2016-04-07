class AddAddressToMembers < ActiveRecord::Migration
  def change
    add_column :members, :address, :string
  end
end
