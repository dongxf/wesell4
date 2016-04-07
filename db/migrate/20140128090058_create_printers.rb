class CreatePrinters < ActiveRecord::Migration
  def change
    create_table :printers do |t|
      t.string   :name
      t.string   :model
      t.string   :imei
      t.string   :status
      t.integer  :copies, null: false, default: 1
      t.integer  :store_id

      t.timestamps
    end
  end
end
