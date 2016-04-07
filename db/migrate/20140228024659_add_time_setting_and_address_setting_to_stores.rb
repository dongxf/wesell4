class AddTimeSettingAndAddressSettingToStores < ActiveRecord::Migration
  def change
    add_column :stores, :time_setting, :string
    add_column :stores, :address_setting, :string
  end
end
