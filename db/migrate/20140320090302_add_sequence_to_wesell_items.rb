class AddSequenceToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :sequence, :integer, default: 100, null: false
  end
end
