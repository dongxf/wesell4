class AddServiceRadiusToStores < ActiveRecord::Migration
  def change
    add_column :stores, :service_radius, :float
  end
end
