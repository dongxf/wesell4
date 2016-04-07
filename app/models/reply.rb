class Reply < ActiveRecord::Base
  belongs_to :user
  belongs_to :replyable, polymorphic: true
  validates :user_id, :replyable_id, presence: true
end
