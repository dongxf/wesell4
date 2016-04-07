class AddCheckinCountToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :checkin_count, :integer, default: 0
  end
end
