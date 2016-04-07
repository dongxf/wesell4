class AddCssIdToVillages < ActiveRecord::Migration
  def change
    add_column :villages, :css_id, :integer
  end
end
