class AddLinkToStore < ActiveRecord::Migration
  def change
    add_column :stores, :link, :string
  end
end
