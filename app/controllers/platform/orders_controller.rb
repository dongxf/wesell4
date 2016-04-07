require 'wechat_pay'

class Platform::OrdersController < Platform::BaseController
  def index
    request.format = 'csv' if params[:export]

    if current_user.admin?
      @all_orders = Order.includes(:store).unopen
    else
      @all_orders = current_user.instance_orders.includes(:store).unopen
    end

    query_string = query_filter

    if query_string.present?
      @all_orders = @all_orders.where(query_string)
    end

    @orders = @all_orders.page params[:page]

    respond_to do |format|
      format.html
      format.csv do
        @orders = @all_orders
      end
    end
  end

  def stores_manager
    request.format = 'csv' if params[:export]

    if current_user.admin?
      @all_orders = Order.includes(:store).unopen
    else
      @all_orders = current_user.store_orders.includes(:store).unopen
    end

    query_string = query_filter

    if query_string.present?
      @all_orders = @all_orders.where(query_string)
    end

    @orders = @all_orders.page params[:page]

    respond_to do |format|
      format.html { render :index }
      format.csv do
        @orders = @all_orders
        render 'platform/orders/index.csv'
      end
    end
  end

  def list
    @store = Store.find(params[:store_id])
    @time_range = case params[:time_mark]
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
    if params[:status] == "all"
      @orders = @store.orders.includes(:store).where(submit_at: @time_range).page(params[:page])
    else
      @orders = @store.orders.includes(:store).where(status: params[:status], submit_at: @time_range).page(params[:page])
    end
    render :index
  end

  def show
    @order = Order.find params[:id]
    @order_items = @order.order_items
    @customer = @order.customer
    @order_actions = @order.order_actions
  end

  def edit
    @order = Order.find params[:id]
  end

  def update
    if params[:event].present?
      @order.send("#{params[:event]}!")
      @order.order_actions.log @order, @order.status, current_user
    else
      @order.update_attributes order_params
    end
    respond_to do |format|
      format.js
      format.html {
        redirect_to platform_order_path(@order), notice: '订单已更新'
      }
    end
  end

  def switch
    order = Order.find params[:id]
    order.toggle!(:is_test)
    message = order.is_test? ? "Order #{order.id}  设为测试订单" : "Order #{order.id}  设为非测试订单"
    render text: message, layout: false
  end

  def print
    @order = Order.find params[:id]
    flag = @order.print!
    flash[:notice] = flag ? "打印失败" : "成功打印"
    redirect_to platform_orders_path
  end

private

  def order_params
    params.require(:order).permit!
  end

  def query_filter
    query_string = ''

    if params[:customer_id].present?
      query_string += " customer_id = #{params[:customer_id]} "
    end

    if params[:store_id].present?
      query_string += ' and ' unless query_string.blank?
      query_string += " store_id = #{params[:store_id]} "
    end

    if params[:payment_option].present?
      query_string += ' and ' unless query_string.blank?
      query_string += " payment_option = '#{params[:payment_option]}' "
    end

    if params[:payment_status].present?
      query_string += ' and ' unless query_string.blank?
      query_string += " payment_status = '#{params[:payment_status]}' "
    end

    if params[:submit_at_1].present?
      submit_at_1 = params[:submit_at_1]

      query_string += ' and ' unless query_string.blank?
      query_string += " submit_at >= '#{submit_at_1}'"
    end

    if params[:submit_at_2].present?
      submit_at_2 = params[:submit_at_2]

      query_string += ' and ' unless query_string.blank?
      query_string += " submit_at <= '#{submit_at_2}'"
    end

    query_string
  end

end