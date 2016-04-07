class AddOldidToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :oldid, :integer
  end
end
