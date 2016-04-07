class Favor < ActiveRecord::Base
	belongs_to :customer
	belongs_to :village_item

	validates :village_item_id, :customer_id, presence: true

end
