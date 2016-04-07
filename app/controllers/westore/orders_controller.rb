class Westore::OrdersController < Westore::BaseController
  before_filter :get_order, except: [:index, :history, :categories_counter, :order_status, :update_order, :choose_express]
  before_filter :check_status, only: [:edit, :clean]
  before_filter :check_payment, only: [:show]
  before_filter :active_link

  def index
    @orders = current_customer.orders.includes(:store).active.valid.page(params[:page]).per(10)
  end

  def history
    @orders = current_customer.orders.includes(:store).history.page(params[:page]).per(10)
  end

  def show
    @order_items = @order.order_items
    @order_actions = @order.order_actions
  end

  def edit
    #highly buggy
    #set_current_store @store
    @store = @order.try(:store)
    set_current_store @store

    @order_items = @order.order_items.includes(:wesell_item)
    @payment_options = @store.human_payment_options.invert
    # logger.info("============================#{@order.instance.nick}")
    unless @order.instance.app_available?
      @payment_options = @store.human_payment_options.except("wechat").invert
    end
    unless flash[:alert]
      flash.now[:alert] = @order.shipping_charge_tips if @order.shipping_charge > 0
    end
  end

  def update
    @order_items = @order.order_items
    if @order_items.blank?
      redirect_to westore_instance_store_path(@order.instance, @order.store)
      return
    end
    if @order.update_attributes order_params
      @order.calculate_amount
      begin
        if @order.wechat_pay? && @order.amount != 0.0
          @order.waiting_payment!
          redirect_to payment_path(@order)
        elsif @order.alipay_pay? && @order.amount != 0.0
          @order.waiting_payment!
          redirect_to alipay_path(@order)
        else
          @order.submit!
          action_name = "请致电#{@order.store.phone}提醒商家及时处理。"  if @order.store.require_confirm
          action_name = "报名已收到，欢迎转发分享本页面让更多朋友了解，感谢！我们将在今天通过#{@order.customer.instance.nick}向您推送确认消息，如有任何问题请点击下方客服按钮咨询" if @order.store.stype == 'event'
          action_name ||= '下单成功，我们会尽快为您安排！' 
          flash[:notice] = action_name
          redirect_to westore_store_path(@order.store)
        end
      rescue AASM::InvalidTransition => e
        flash[:alert] = @order.message
        logger.info "*********#{e.message}"
        redirect_to westore_order_path(@order)
      end
    else
      render :edit
    end
  end

  def comment
    if request.patch?
      @order.update_attributes order_params
      @order.confirm! unless @order.confirmed?
      redirect_to action: :show
      return
    end
  end

  def hurry_up
    @order.hurry_up!
    redirect_to action: :show
  end

  def clean
    @store = @order.try(:store)
    @order.order_items.destroy_all
    @instance = @order.instance
    redirect_to westore_instance_store_path(@instance, @store)
  end

  def categories_counter
    @order = Order.find params[:order_id]
    render json: {code: 0, message: '', result: {data: @order.categories_counter}}
  end

  def order_status
    @order = Order.find params[:id]
    @order_actions = @order.order_actions
    @no_bottom = true
  end

  def update_order
    @order = Order.find params[:id]
    #There's bug
    #@current_customer = Instance.find_by(name: 'fwdesk').customers.find(session[:customer_id_4])
    #Security issus
    @current_customer = Customer.find_by id: session[:customer_id_4]
    if params[:event].present?
      @order.send("#{params[:event]}!")
      @order.order_actions.log @order, @order.status, @current_customer
    else
      @order.update_attributes order_params
    end
  end

  def choose_express
    #逻辑上应该跟上面的update_order是共通的
    @order = Order.find params[:id]
    #There's bug
    #@current_customer = Instance.find_by(name: 'fwdesk').customers.find(session[:customer_id_4])
    #Security issus
    @current_customer = Customer.find_by id: session[:customer_id_4]
    @express = Express.find params[:express]
    @order.express = @express
    if @order.save
      @order.repost!
      @order.order_actions.log @order, @order.status, @current_customer
    end
  end

private

  def order_params
    params[:order][:order_config_option_ids].reject! { |i| i.empty? } if params[:order][:order_config_option_ids].present?
    params.required(:order).permit!
  end

  def get_order
    @order = current_order if params[:current_order]
    @order ||= current_customer.orders.find_by id: params[:id]
    @order ||= current_order
    @store = @order.try(:store)
    logger.info "---- get_order order: #{@order.try(:id)} customer: #{current_customer.try(:id)} params: #{params} ----"
    logger.info "---- current_order: #{current_order.try(:id)}  is not for current_customer #{current_customer.try(:id)} ----" if current_customer.blank? || current_customer != current_order.customer
    logger.info "---- @order: #{@order.try(:id)}  is not for current_customer #{current_customer.try(:id)} ---- " if current_customer.blank? || current_customer != @order.try(:customer)
  end

  def check_status
    unless @order.editable?
      if @order.cash_pay? || @order.paid?
        redirect_to westore_order_path(@order)
      elsif @order.wechat_pay?
        redirect_to payment_path(@order)
      elsif @order.alipay_pay?
        redirect_to alipay_path(@order)
      end
    end
  end

  def check_payment
    if @order.open?
      redirect_to edit_westore_order_path(@order)
    else
      redirect_to payment_path(@order) unless @order.cash_pay? || @order.paid?
    end
  end

  def active_link
    @active_link = :orders
  end
end
