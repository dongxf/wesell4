class AddMonetaryToStores < ActiveRecord::Migration
  def change
    add_column :stores, :monetary_unit, :string
  end
end
