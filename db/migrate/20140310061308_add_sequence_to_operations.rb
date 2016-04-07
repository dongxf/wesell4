class AddSequenceToOperations < ActiveRecord::Migration
  def change
    add_column :operations, :sequence, :integer, default: 1000, null: false
  end
end
