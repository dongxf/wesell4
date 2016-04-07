class CreateExpressStores < ActiveRecord::Migration
  def change
    create_table :express_stores do |t|
      t.integer :store_id
      t.integer :express_id

      t.timestamps
    end
  end
end
