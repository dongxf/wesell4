class AddSloganToStores < ActiveRecord::Migration
  def change
    add_column :stores, :slogan, :string, null: false, default: ""
  end
end
