class WechatKey < ActiveRecord::Base
  belongs_to :instance

  validates :tips, :key, :msg_type, :content, presence: true
  validates_uniqueness_of :key, scope: :instance_id
  mount_uploader :banner, BannerUploader

  TYPES = {
    text: '纯文本',
    news:  '图文消息'
  }
end
