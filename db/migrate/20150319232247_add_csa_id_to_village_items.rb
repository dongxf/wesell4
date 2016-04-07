class AddCsaIdToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :csa_id, :integer
  end
end
