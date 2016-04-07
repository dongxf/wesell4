class Report < ActiveRecord::Base
	belongs_to :store

	def order_average
		avg = valid_orders == 0 ? 0 : total_income/valid_orders
		avg.round(2)
	end

	def item_average
		avg = item_sold == 0 ? 0 : total_income/item_sold
		avg.round(2)
	end
end
