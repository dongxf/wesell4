class Offer < ActiveRecord::Base
  belongs_to :village_item

  validates_presence_of :started_at, :title, :info, :duration

  def effective?
    started_at.to_date + duration - 1 >= Time.now.to_date
  end

  def newest

  end
end
