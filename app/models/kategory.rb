class Kategory < ActiveRecord::Base
  belongs_to :instance, counter_cache: true
  has_many :operations
  has_many :stores, through: :operations

  validates_presence_of :name, :instance_id
  validates_uniqueness_of :name, scope: :instance_id

  mount_uploader :logo, LogoUploader

  default_scope { order('kategories.sequence ASC') }

  before_destroy :clean_operations

  def clean_operations
    operations.update_all kategory_id: nil
  end
end
