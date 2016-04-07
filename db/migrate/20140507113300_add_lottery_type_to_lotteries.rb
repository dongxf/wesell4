class AddLotteryTypeToLotteries < ActiveRecord::Migration
  def change
    add_column :lotteries, :lottery_type, :integer, default: 0, null: false
  end
end
