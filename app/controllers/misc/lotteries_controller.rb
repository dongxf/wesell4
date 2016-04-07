require 'creditable'
require 'lottery_app'

class Misc::LotteriesController < Misc::BaseController
  before_filter :no_header
  before_filter :check_duplication, :check_credit, only: [:new]
  before_filter :get_lottery_app, only: [:create, :award_info]

  def index
    @lotteries = current_customer.lotteries.page params[:page]
    # redirect_to action: :new
  end

  def create
    redirect_to text: "请关注微信公众号 #{@instance.try(:nick)} 后再领取赠送彩票" and return if current_customer.nil?

    if current_customer.lotteries.count > @instance.lottery_pick_max
      redirect_to action: "index", notice: '您的最高彩票赠送次数额度已经用完'
      return
    end

    @lottery = Lottery.new lottery_params
    @lottery.instance = @instance

    if @lottery.save(validate: false)
      @lottery_app.get_lottery @lottery
      logger.info @lottery.inspect
      render text: "错误!" and return if @lottery.destroyed?

      redirect_to misc_lottery_path(@lottery)
    else
      render :new and return
    end
  end

  def show
    @lottery = current_customer.lotteries.find(params[:id])
    @instance = @lottery.instance
    numbers = @lottery.vote_nums.split('|')[0]
    numbers = numbers.split('/')
    @reds = numbers[0..5]
    @blue = numbers[-1]
  end

  def award_info
    @lottery = current_customer.lotteries.find params[:id]
    if @lottery
      @datas = @lottery_app.get_lottery_records 2, 1
    else
      @datas = []
    end
  end

private

  def lottery_params
    params.require(:lottery).permit!
  end

  def check_credit
    begin
      @instance = Instance.find params[:instance_id]
      raise Creditable::CreditNotEnough unless @instance.sub_lottery?
      @instance.calculate_credit :lottery
    rescue Creditable::CreditNotEnough
      render 'credit_not_enough' and return
    end
  end

  def check_duplication
    #### 关注送彩票
    @lottery = Lottery.where(customer_id: current_customer.id, lottery_type: 0).first
    @lottery ||= Lottery.new(customer_id: current_customer.id, lottery_type: 0)
    unless @lottery.new_record?
      redirect_to misc_lottery_path(@lottery)
    end
  end

  def get_lottery_app
    @lottery_app = LotteryApp.new current_customer
    @instance = current_customer.instance
  end
end
