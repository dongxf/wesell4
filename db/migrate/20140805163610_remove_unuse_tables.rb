class RemoveUnuseTables < ActiveRecord::Migration
  def up
    drop_table :yellow_pages
    drop_table :yellow_items
    drop_table :yellow_cates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
