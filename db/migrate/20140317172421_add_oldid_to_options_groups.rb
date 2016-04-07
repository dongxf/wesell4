class AddOldidToOptionsGroups < ActiveRecord::Migration
  def change
    add_column :options_groups, :oldid, :integer
  end
end
