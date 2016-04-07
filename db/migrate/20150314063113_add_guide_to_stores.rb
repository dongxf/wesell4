class AddGuideToStores < ActiveRecord::Migration
  def change
    add_column :stores, :guide, :text
  end
end
