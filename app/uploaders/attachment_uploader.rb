class AttachmentUploader < CarrierWave::Uploader::Base

  storage :qiniu
	def store_dir
		time = Time.now.strftime('%Y%m%d%H%M')
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}/#{time}"
	end

	def filename
		original_filename
	end

	# def default_url
	#   # For Rails 3.1+ asset pipeline compatibility:
	#   "http://#{self.qiniu_bucket_domain}/uploads/defaults/" + [version_name, "default_#{mounted_as}.jpg"].compact.join('_')
	# end
end
