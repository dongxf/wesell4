class Member < ActiveRecord::Base
  has_many :customers
  belongs_to :instance

  validates_presence_of :instance_id, :name, :phone, :birthday
  attr_accessor :identifying_code
end
