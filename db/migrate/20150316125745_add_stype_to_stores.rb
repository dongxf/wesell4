class AddStypeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :stype, :string, default: 'normal'
  end
end
