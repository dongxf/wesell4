class AddEventInfoToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :event_location, :string
    add_column :wesell_items, :event_time, :string
    add_column :wesell_items, :event_tip, :string
  end
end
