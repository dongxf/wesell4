class Record < ActiveRecord::Base
	belongs_to :customer
	belongs_to :instance

  default_scope -> { order("created_at DESC") }
end
