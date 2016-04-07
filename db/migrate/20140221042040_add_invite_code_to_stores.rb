class AddInviteCodeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :invite_code, :string
  end
end
