class AddDefaultVillageIdToCustomers < ActiveRecord::Migration
  def up
    add_column :customers, :default_village_id, :integer
    remove_column :village_items, :default_village_id

  end

  def down
    add_column :village_items, :default_village_id, :integer
    remove_column :customers, :default_village_id
  end
end
