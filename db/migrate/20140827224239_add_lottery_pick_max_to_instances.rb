class AddLotteryPickMaxToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :lottery_pick_max, :integer, default: 1
  end
end
