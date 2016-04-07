class AddAddonHintsToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :addon_hints, :string
  end
end
