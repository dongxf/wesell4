class AddAdminEmailToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :admin_email, :string
  end
end
