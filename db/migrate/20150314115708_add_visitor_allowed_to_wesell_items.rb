class AddVisitorAllowedToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :visitor_allowed, :boolean, default: false
  end
end
