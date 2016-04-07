class AddSeveralColumnsToVillages < ActiveRecord::Migration
  def change
    add_column :villages, :slogan, :string
    add_column :villages, :desc, :text
    add_column :villages, :latitude, :float
    add_column :villages, :longitude, :float
    add_column :villages, :logo, :string
    add_column :villages, :banner, :string
  end
end
