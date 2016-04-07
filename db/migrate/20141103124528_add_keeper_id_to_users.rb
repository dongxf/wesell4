class AddKeeperIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :keeper_id, :integer
  end
end
