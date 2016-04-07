class AddReferralToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :referral_id, :integer
    add_column :village_items, :owner_id, :integer
  end
end
