#encoding: utf-8
class Lottery < ActiveRecord::Base
  validates_presence_of :game_type, :issue, :seq_no, :flowid, :amount, :vote_type, :vote_nums, :multi, :comm_key
  validates_format_of :phone, :with => /\A[0-9]\d{5,11}\z/, message: '亲，手机号码无效！'

  belongs_to :customer
  belongs_to :instance
  belongs_to :order

  default_scope { order('lotteries.created_at DESC') }

  before_create do |lottery|
    lottery.random_unique_id = SecureRandom.uuid[0..7]
  end
  # validates_associated :customer, message: "每人仅限送一次彩票"

  # LOTTERY_TYPE = %w{关注送彩票 首单送彩票}
  LOTTERY_TYPE = %w{关注送彩票}

  def human_lottery_type
    LOTTERY_TYPE[lottery_type]
  end

end
