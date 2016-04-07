require 'alipay'

class Westore::AlipayController < Westore::BaseController
  skip_before_filter :verify_authenticity_token, only: [:notify]

  def pay
    @order = Order.find params[:order_id]
    @store = @order.store
    alipay = Alipay::Util.new @order
    url = alipay.execute_url
    redirect_to url
  end

  def callback
    @order = Order.find params[:out_trade_no]
    #unless @order.transid.present? && @order.paid?
    if @order.transid.blank? && params[:trade_no]
      @order.transid = params[:trade_no] 
      @order.save
    end
    @order.paid! if params[:result] == 'success' && !@order.paid?
    redirect_to westore_order_path(@order)
  end

  def notify
    @order = Order.find params[:order_id]
    unless @order.transid.present? && @order.paid?
      alipay = Alipay::Util.new @order
      p_hash = params.slice('service', 'v', 'sec_id', 'notify_data')
      sign   = alipay.sign p_hash, false
      if sign == params[:sign]
        xml = Nokogiri::XML params["notify_data"]
        trade_no = xml.at_css('trade_no').content
        @order.update_attribute :transid, trade_no
        @order.paid!
        # @order.submit!
      else
        render status: 404 and return
      end
    end
    render text: 'success', layout: false
  end
end
