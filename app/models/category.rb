class Category < ActiveRecord::Base
  belongs_to :store
  has_many :wesell_items, dependent: :restrict_with_exception
  has_many :order_items

  validates_uniqueness_of :name, scope: :store_id
  validates_presence_of :name, :sequence

  default_scope { order('categories.sequence ASC') }
  scope :active, -> { where('products_count > 0 and activated = true')}
end
