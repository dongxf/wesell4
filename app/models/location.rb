class Location < ActiveRecord::Base
  belongs_to :customer

  def expired?
    2.hours.ago > updated_at
  end
end
