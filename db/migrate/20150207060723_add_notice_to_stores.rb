class AddNoticeToStores < ActiveRecord::Migration
  def change
    add_column :stores, :notice, :text
  end
end
