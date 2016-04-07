class OrderConfigOption < ActiveRecord::Base
  belongs_to :order_config
  belongs_to :store

  validates_presence_of :name, :price
  validates_uniqueness_of :name, scope: [:order_config_id]

  delegate :monetary_tag, to: :store

  def label mystore=nil
    mystore ||= self.store
    price == 0 ? name : "#{name} [+ #{mystore.monetary_tag}#{price}]"
  end
end
