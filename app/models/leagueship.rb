class Leagueship < ActiveRecord::Base
  belongs_to :village
  belongs_to :village_item
end
