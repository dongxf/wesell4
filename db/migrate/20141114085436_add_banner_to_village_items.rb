class AddBannerToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :banner, :string
  end
end
