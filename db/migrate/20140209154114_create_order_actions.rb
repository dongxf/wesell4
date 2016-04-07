class CreateOrderActions < ActiveRecord::Migration
  def change
    create_table :order_actions do |t|
      t.integer :order_id
      t.string :action_type

      t.timestamps
    end
  end
end
