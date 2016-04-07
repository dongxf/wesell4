class Binder < ActiveRecord::Base
  belongs_to :customer
  belongs_to :target, polymorphic: true
end
