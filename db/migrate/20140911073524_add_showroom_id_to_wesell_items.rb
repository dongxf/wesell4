class AddShowroomIdToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :showroom_id, :integer, default: nil
  end
end
