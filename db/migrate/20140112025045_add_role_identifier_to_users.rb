class AddRoleIdentifierToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role_identifier, :string
  end
end
