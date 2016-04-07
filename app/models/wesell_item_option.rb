class WesellItemOption < ActiveRecord::Base
  belongs_to :options_group
  belongs_to :wesell_item
  has_many :order_item_options

  validates_presence_of :name, :price
  validates_uniqueness_of :name, scope: [:options_group_id]
  validates_numericality_of :price, greater_than_or_equal_to: 0

  default_scope { order('wesell_item_options.sequence ASC') }

  def label store=nil
    store ||= self.wesell_item.store
    price == 0 ? name : "#{name} [+#{store.monetary_tag}#{price}]"
  end

end
