class AddOpeningHourToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :opening_hours, :string
  end
end
