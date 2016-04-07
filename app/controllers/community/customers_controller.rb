class Community::CustomersController < Community::BaseController
	def favor
    @customer = current_customer
    @customer ||= Customer.find_by id: params[:customer_id]
    @village_items = @customer.village_items.permit.page(params[:page]).per(9)
    @village = @customer.instance.villages.first
    @rmsg = '我的收藏'
    render 'community/villages/search'
	end
  def chat
    @customer = Customer.find parmas[:id] if params[:id]
    @customer ||= Customer.find params[:customer_id] if params[:customer_id]
    if @customer
      @title = params[:t]
      @summary = params[:s]
      @url = params[:u]
      @note = params[:n]
      if params[:mid] == '1'
        @title = '感谢您分享黄页信息'
        @summary = '由于信息不全我们暂时无法核实并录入该信息，欢迎您重新提交！'
      end
      @title ||= '您收到一条来自客服汉纸的消息'
      @summary ||= '客服汉纸邀请您开始对话'
      @note ||= '点击详情接入服务专线'
      @url ||= @customer.instance.fixed_mechat_url
      @url ||= "tel:#{@customer.instance.phone}"
      msg = @customer.send_form @summary, @title, @note, @url
      render text: "已向#{@customer.id}(#{@customer.nickname})发送如下消息：[#{@title}] [#{@summary}] [#{@note}] [#{@url}]"
    else
      render text: '未找到客户号!'
    end
  end
  def echo
    if session[:wx_38_oid].blank?
      msg = '未关注过幸福大院' 
    else
      cst = Customer.find_by openid: session[:wx_38_oid]
      if cst
        msg = "客户号#{cst.id}，#{cst.subscribed ? '关注中' : '已取消'}"
      else
        msg = '幸福大院关注无效'
      end
    end
    render text: msg
  end
end
