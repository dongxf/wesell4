class AddInviteCodeToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :invite_code, :string
  end
end
