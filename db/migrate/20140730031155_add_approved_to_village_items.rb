class AddApprovedToVillageItems < ActiveRecord::Migration
  def change
  	add_column :village_items, :approved, :boolean, default: false
  	add_column :village_items, :doc, :string
  	add_column :village_items, :approved_start_at, :datetime
  	add_column :village_items, :approved_end_at, :datetime
  end
end
