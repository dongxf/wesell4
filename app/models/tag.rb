class Tag < ActiveRecord::Base
	has_many :sub_tags, dependent: :destroy
	has_many :village_items, through: :sub_tags
	validates :name, presence: true, :uniqueness => true

	def self.optgroup
		array = []
    Tag.all.each_with_index do |tag, index|
      array << [tag.name, tag.sub_tags.pluck(:name)]
    end
    array
	end
end
