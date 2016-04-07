class AddRequireConfirmToStore < ActiveRecord::Migration
  def change
    add_column :stores, :require_confirm, :boolean, default: false
  end
end
