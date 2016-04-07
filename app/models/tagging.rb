class Tagging < ActiveRecord::Base
	belongs_to :sub_tag
	belongs_to :village_item
end
