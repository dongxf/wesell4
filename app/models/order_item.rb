class OrderItem < ActiveRecord::Base
  belongs_to :order, counter_cache: :items_count
  belongs_to :wesell_item
  belongs_to :category
  has_many :order_item_options, dependent: :destroy
  has_many :wesell_item_options, through: :order_item_options

  validates :quantity, presence: true, numericality: true
  validates_numericality_of :quantity, greater_than: 0
  validates :wesell_item_id, :presence => true, :uniqueness => {:scope => :order_id}
  before_create :set_item_attrs

  delegate :monetary_unit, :monetary_tag, to: :wesell_item

  def human_price
    "#{monetary_tag}#{unit_price}/#{unit_name}"
  end

  def calculate_order_amount
    self.order.reload.calculate_amount
  end

  def total_price
    price = unit_price
    order_item_options.each do |option|
      price += option.price
    end
    total = price * quantity
  end

  def set_item_attrs
    self.name        = wesell_item.name
    self.category_id = wesell_item.category_id
    self.unit_price  = wesell_item.price
    self.unit_name   = wesell_item.unit_name
  end

  def set_options option_ids
    option_ids.each do |i|
      wesell_item_option = WesellItemOption.find i
      order_item_option = self.order_item_options.find_or_initialize_by wesell_item_option_id: i
      order_item_option.update_attributes price: wesell_item_option.price, name: wesell_item_option.name
    end
    calculate_order_amount
  end
end
