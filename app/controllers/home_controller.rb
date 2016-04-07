class HomeController < ApplicationController
  before_filter :authenticate_user!, only: [:dashboard]
  layout 'platform', only: [:dashboard]

  def index
    resource = User.new
    @users_count = User.count
    @customers_count = Customer.count
    @stores_count = Store.count
    @instances_count = Instance.count
    @orders_count = Order.count
    @orders_income = Order.sum(:amount).to_i
  end

  def dashboard
    render 'vdash' and return if current_user.is_vusr?
    @instances = current_user.instances.page(params[:page])
    @stores = current_user.stores.online.page(params[:page])
    @operated_stores = current_user.operated_stores.online.page(params[:page])
    @customers = current_user.customers.page params[:page]
    @time_mark = params[:time_mark]
    @time_range = case @time_mark
                  when "someday"
                    time = Time.zone.parse params[:time_pick]
                    time.midnight..time.end_of_day
                  when "week"
                    Date.yesterday.ago(1.week).midnight..Date.yesterday.end_of_day
                  when "month"
                    Date.yesterday.ago(1.month).midnight..Date.yesterday.end_of_day
                  else
                    Date.today.midnight..Date.today.end_of_day
                  end
  end

  def pricing
  end

  def life
    @order = Order.new
    render layout: "housing"
  end

  def team
    @no_contact = true
  end

  def forum
    news_forum = Forem::Forum.find_by(slug: params[:slug])
    redirect_to root_path and return if news_forum.blank?
    @top5 = news_forum.topics.order("views_count DESC").first 5
    @topics = news_forum.topics.order('created_at DESC').page(params[:page]).per(6)
  end

  def test
    render 'wx_pay'
  end

  def post
    news_forum = Forem::Forum.find_by(slug: params[:slug])
    redirect_to root_path and return if news_forum.blank?
    @top5 = news_forum.topics.order("views_count DESC").first 5
    @topic = Forem::Topic.find_by id: params[:id]
    @forum = @topic.try(:forum)
    @posts = @topic.try(:posts)
    @post = @posts.try(:first)
  end
end
