class DropRatingsTable < ActiveRecord::Migration
  def up
    drop_table :ratings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
