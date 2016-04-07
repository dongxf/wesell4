class ChangeWestoreIdFieldForShowrooms < ActiveRecord::Migration
  def up
    rename_column :showrooms, :westore_id, :store_id
  end

  def down
    rename_column :showrooms, :store_id, :westore_id
  end
end
