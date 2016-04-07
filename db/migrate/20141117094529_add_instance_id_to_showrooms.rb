class AddInstanceIdToShowrooms < ActiveRecord::Migration
  def change
    add_column :showrooms, :instance_id, :integer
  end
end
