class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.date :report_date
      t.integer :store_id
      t.integer :total_orders
      t.integer :valid_orders
      t.integer :total_income
      t.integer :item_sold

      t.timestamps
    end
  end
end
