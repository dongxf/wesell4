class ExpressStore < ActiveRecord::Base
  belongs_to :express
  belongs_to :store
end
