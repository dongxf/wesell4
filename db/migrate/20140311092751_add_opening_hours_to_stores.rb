class AddOpeningHoursToStores < ActiveRecord::Migration
  def change
    add_column :stores, :opening_hours, :string
  end
end
