Forem::Post.class_eval do
  has_many :pictures, dependent: :destroy

  mount_uploader :attachment, AttachmentUploader
  validate :file_size

  def file_size
    if attachment.size.to_f/(1000*1000) > 1
      errors.add(:attachment, "请上传小于 1MB 的附件")
    end
  end
end