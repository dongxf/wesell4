class AddOldidToUsers < ActiveRecord::Migration
  def change
    add_column :users,        :oldid, :integer
    add_column :instances,    :oldid, :integer
    add_column :stores,       :oldid, :integer
    add_column :categories,   :oldid, :integer
    add_column :wesell_items, :oldid, :integer
    add_column :customers,    :oldid, :integer
    add_column :orders,       :oldid, :integer
  end
end
