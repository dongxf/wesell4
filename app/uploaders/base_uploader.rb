# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  # include ::CarrierWave::Backgrounder::Delay

  storage :qiniu

  # if Rails.env.development?
  #   self.qiniu_bucket = "tangpin-dev"
  #   self.qiniu_bucket_domain = "tangpin-dev.u.qiniudn.com"
  # end

  # See also:
  # https://github.com/qiniu/ruby-sdk/issues/48
  # http://docs.qiniu.com/api/put.html#uploadToken
  # http://docs.qiniutek.com/v3/api/io/#uploadToken-asyncOps
  def qiniu_async_ops
    commands = []
    %W(small little middle large).each do |style|
      commands << "http://#{self.qiniu_bucket_domain}/#{self.store_dir}/#{self.filename}/#{style}"
    end
    commands
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    "http://#{self.qiniu_bucket_domain}/uploads/defaults/" + [version_name, "default_#{mounted_as}.jpg"].compact.join('_')
  end


  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      @name ||= ::SecureRandom.uuid
      @extname ||= File.extname(current_path).downcase

      "#{@name}#{@extname}"
    end
  end

end
