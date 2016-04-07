require 'wechat_pay'

class Westore::PaymentController < Westore::BaseController
  include WechatPay::Signature

  before_filter :check_payment_status, :get_instance, only: [:pay]
  skip_before_action :verify_authenticity_token
  skip_before_action :current_customer, except: [:pay]

  def pay
    @store   = @order.store
    @instance = @order.instance
    payment  = WechatPay::Util.new @order
    settings = {
      notify_url:       notify_payment_url(@order),
      spbill_create_ip: request.ip
    }
    @package       = payment.get_package(settings)
    @app_id        = @instance.app_id
    @app_key       = @instance.pay_sign_key
    @pay_sign      = sign_pay(payment.get_pay_params(@package))
  end

  def notify
    @order = Order.find params[:out_trade_no]
    if params[:trade_state].to_i == 0 && params[:transaction_id].present?
      @order.update_column :transid, params[:transaction_id]
      # @order.submit! if @order.require_payment?
      @order.paid! if @order.unpaid?
    end
    render text: 'success', layout: false
  end

  def warning
    render text: 'success', layout: false
  end

protected

  def get_instance
    @instance = Instance.find_by(name: params[:instance_name])
  end

  def check_payment_status
    @order   = Order.find params[:order_id]
    redirect_to Westore_order_path(@order) if @order.paid?
  end

end
