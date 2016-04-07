class OrderConfig < ActiveRecord::Base
  STYLES = {
    '任选一种' => 0,
    '允许多种组合' => 1
  }

  belongs_to :store
  has_many :order_config_options, dependent: :destroy
  accepts_nested_attributes_for :order_config_options, allow_destroy: true

  validates_presence_of :name, :style
  validates_uniqueness_of :name, scope: [:store_id]

  def human_style
    STYLES.key(style)
  end
end
