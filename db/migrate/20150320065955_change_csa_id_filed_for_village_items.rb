class ChangeCsaIdFiledForVillageItems < ActiveRecord::Migration
  def change
    rename_column :village_items, :csa_id, :cca_id
  end
end
