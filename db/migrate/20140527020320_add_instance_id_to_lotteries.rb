class AddInstanceIdToLotteries < ActiveRecord::Migration
  def change
    add_column :lotteries, :instance_id, :integer
    add_index :lotteries, [:instance_id, :customer_id, :order_id]
    # Lottery.find_each do |l|
    #   l.instance_id = l.customer.instance_id if l.customer.instance.present?
    #   l.instance_id ||= l.order.instance_id  if l.order && l.order.instance.present?
    #   l.save
    # end
  end
end
