class OptionsGroup < ActiveRecord::Base
  STYLES = {
    '任选一种' => 0,
    '允许多种组合' => 1
  }

  belongs_to :wesell_item, counter_cache: true
  has_many :wesell_item_options, dependent: :destroy
  accepts_nested_attributes_for :wesell_item_options, allow_destroy: true

  validates_presence_of :name, :style
  validates_uniqueness_of :name, scope: [:wesell_item_id]

  after_save :check_wesell_item_options

  def human_style
    STYLES.key(style)
  end

  def check_wesell_item_options
    if wesell_item_options.blank?
      self.destroy
    end
  end
end
