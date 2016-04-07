class AddShowBuyersToStores < ActiveRecord::Migration
  def change
    add_column :stores, :show_buyers, :boolean, default: false
  end
end
