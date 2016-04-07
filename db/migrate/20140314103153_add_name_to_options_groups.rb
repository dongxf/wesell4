class AddNameToOptionsGroups < ActiveRecord::Migration
  def change
    add_column :options_groups, :name, :string, null: false, default: ''
  end
end
