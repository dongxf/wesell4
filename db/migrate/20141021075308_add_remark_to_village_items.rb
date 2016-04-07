class AddRemarkToVillageItems < ActiveRecord::Migration
  def change
    add_column :village_items, :remark, :string
  end
end
