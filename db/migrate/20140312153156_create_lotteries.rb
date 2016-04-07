class CreateLotteries < ActiveRecord::Migration
  def change
    create_table :lotteries do |t|
      t.integer :customer_id
      t.integer :order_id
      t.string :phone
      t.string :comm_key

      t.integer :game_type
      t.integer :issue
      t.integer :seq_no
      t.integer :amount
      t.integer :vote_type
      t.integer :multi
      t.string :flowid
      t.string :vote_nums
      t.string :random_unique_id

      t.timestamps
    end
  end
end
