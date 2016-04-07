class AddBannerToWesellItems < ActiveRecord::Migration
  def change
    add_column :wesell_items, :banner, :string
  end
end
