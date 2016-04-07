class SubTag < ActiveRecord::Base
	belongs_to :tag
	has_many   :taggings, dependent: :destroy
	has_many   :village_items, through: :taggings
	validates  :name, presence: true, :uniqueness => true
	validates  :tag_id, presence: true
end
