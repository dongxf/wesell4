class AddAdminPhoneToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :admin_phone, :string
  end
end
