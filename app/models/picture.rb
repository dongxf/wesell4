class Picture < ActiveRecord::Base
	# belongs_to :post, class_name: "Forem::Post"

	mount_uploader :pic, BaseUploader

	def to_jq_upload
	  {
	    "url" => self.pic.url
	  }
	end
end
