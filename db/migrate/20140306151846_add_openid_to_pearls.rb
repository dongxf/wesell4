class AddOpenidToPearls < ActiveRecord::Migration
  def change
    add_column :pearls, :openid, :string
  end
end
