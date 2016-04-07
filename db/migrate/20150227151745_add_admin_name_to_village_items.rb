class AddAdminNameToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :admin_name, :string
  end
end
