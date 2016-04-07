class UpdateCsniForOrders < ActiveRecord::Migration
  def change
    Customer.find_each do |customer|
      customer.orders.where("submit_at IS NOT NULL").order("submit_at asc").each_with_index do |order, index|
        order.update_attribute(:csni, index+1)
      end
    end
  end
end
