class Misc::BaseController < InheritedResources::Base

  layout 'misc'

  before_filter :parse_query, :authenticate_openid!
  helper_method :current_customer,
                :current_instance,
                :current_store,
                :current_order

  rescue_from ActiveRecord::RecordNotFound do |e|
    logger.info e.message
    logger.info e.backtrace
    no_permission
  end
  rescue_from NoMethodError do |e|
    logger.info e.message
    logger.info e.backtrace
    no_permission
  end

  protected

  def parse_query

    logger.info "tbd1: #{params}"

    #at this time, all customer must belongs to specific instacne
    @current_instance = Instance.find_by(id: params[:instance_id]) if params[:instance_id].present?
    @current_store = Store.find_by(id: params[:store_id]) if params[:store_id].present?
    @current_order = Order.find_by(id: params[:order_id]) if params[:order_id].present?
    @current_store ||= @current_order.store if @current_order && @current_order.store
    @current_instance ||= @current_order.instance if @current_order && @current_order.instance

    if params[:id]
      tid = params[:id]
      case params[:controller]
      when 'westore/instances'
        @current_instance ||= Instance.find_by id: tid
      when 'westore/categories'
        cc = Category.find_by id: tid
        @current_store ||= cc.store if cc
        @current_instance ||= @current_store.instances.first if @current_store && @current_store.instances.first
      when 'westore/members'
        cm = Member.find_by id: tid
        @current_instance ||= cm.instance if cm && cm.instance # attention: there's some nil instance in Member
      when 'westore/order_items'
        oi = OrderItem.find_by id: tid
        @current_instance ||= oi.order.instance if oi && oi.order && oi.order.instance
      when 'westore/orders', 'westore/payment'
        # "/westore/orders/633618"
        @current_order ||= Order.find_by id: tid
        @current_store ||= @current_order.store if @current_order && @current_order.store
        @current_instance ||= @current_order.instance if @current_order && @current_order.instance
      when 'westore/stores'
        @current_store ||= Store.find_by id: tid
        @current_instance ||= @current_store.instances.first if @current_store && @current_store.instances.first
      when 'westore/wesell_items'
        wi = WesellItem.find_by id: tid
        @current_store ||= wi.store if wi
        @current_instance ||= @current_store.instances.first if @current_store && @current_store.instances.first
      else
        logger.info "==== westore parse nil===="
      end
    end
    
    if params[:product_id]
      #/westore/stores/add_item?product_itd=xxxx
      wi = WesellItem.find_by id: params[:product_id]
      @current_store ||= wi.store if wi
      @current_instance ||= @current_store.instances.first if @current_store && @current_store.instances.first
    end

    session[:instance_id_4] = @current_instance.id if @current_instance.present?
    session[:store_id_4] = @current_store.id if @current_store.present?

    # for those controller without any id such as westore/members
    @curent_instance = current_instance if current_instance.present?

    logger.info "tbd2: instance#{@currrent_instance} store#{@current_store} order#{@current_order}"

  end

  def authenticate_openid!
    # 判断是否使用oauth
    we_agent = request.user_agent.include?('MicroMessenger') || request.user_agent.include?('Windows Phone')
    return filter_customer_cid if !current_instance.present? || !we_agent || !current_instance.wechat_auth?
    logger.info("==== oauth start: instance #{current_instance} ====")
    # 当session中没有对应instance的openid时，则为非登录状态
    iid = current_instance.id
    appid = current_instance.app_id
    appsc = current_instance.app_secret
    oidkey = "wx_#{iid}_oid"
    if session[oidkey].blank?
      code = params[:code]
    # 如果code参数为空，则为认证第一步，重定向到微信认证
      if code.nil?
        logger.info("==== oauth step 1 redirect ====")
        redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{request.url}&response_type=code&scope=snsapi_base&state=#{request.url}#wechat_redirect"
      end
      #如果code参数不为空，则认证到第二步，通过code获取openid，并保存到session中
      begin
        url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{appsc}&code=#{code}&grant_type=authorization_code"
        session[oidkey] = JSON.parse(URI.parse(url).read)["openid"]
        logger.info("==== oauth step 2, session[#{oidkey}] #{session[oidkey]} ====")
      rescue Exception => e
        logger.info("==== oauth step 2 exception: #{e.to_s} using old method ====")
        return filter_customer_cid
      end
    end
    customer = Customer.find_by openid: session[oidkey]
    if !customer.present?
      customer = current_instance.customers.create(subscribed: false, openid: session[oidkey])
      logger.info("==== create new customer: #{customer} ====")
    end
    set_current_customer(customer)
  end

  def filter_customer_cid
    if params[:customer_cid].present?
      customer = Customer.find_by cid: params[:customer_cid]
      if customer.present?; set_current_customer(customer) else logger.info "---- filter customer failed  #{params[:customer_cid]} ----" end
      redirect_to request.url.gsub(/customer_cid=\w{32}/, '')
    end
  end

  def current_customer
    return @current_customer if @current_customer
    customer = @current_instance.customers.find_by(id: session[:customer_id_4]) if session[:customer_id_4] && @current_instance #if use current_instance will recurse
    if customer.present?; return set_current_customer(customer) else logger.info "==== restore customer failed  #{@current_instance} #{session[:customer_id_4]} ====" end
    customer = @current_instance.customers.create(subscribed: false) if @current_instance
    if customer.present?; return set_current_customer(customer) else logger.info "==== create customer failed  #{@current_instance.try(:id)} ====" end
    logger.info "==== current_customer is nil #{@current_instance.try(:id)} ====" # line return true
    @current_customer = nil
  end

  def set_current_customer(customer)
    session[:customer_id_4] = customer.id
    old_ip = customer.current_visit_ip
    customer.update_attributes(current_visit_ip: request.remote_ip, last_visit_ip: old_ip)
    @current_customer = customer
  end

  def current_instance
    return @current_instance if @current_instance
    instance = Instance.find_by id: session[:instance_id_4] if session[:instance_id_4]
    if instance.present?; return set_current_instance(instance) else logger.info "==== restore instance failed 1 - from instance_session ====" end
    instance = current_customer.instance if current_customer
    if instance.present?; return set_current_instance(instance) else logger.info "==== restore instance failed 2 - from current_customer  ====" end
    @current_instance = nil
  end

  def set_current_instance(instance)
    session[:instance_id_4] = instance.id
    @current_instance = instance
  end

  def current_store
    @current_store = Store.find session[:store_id_4] if session[:store_id_4]
  end

  def set_current_store store
    session[:store_id_4] = store.id
    @current_store = store
  end

  def current_order
    @current_order ||= current_customer.init_order @current_instance, @current_store if current_customer.present? && current_instance.present? && current_store.present?
    logger.info "==== get current_order as: #{@current_order.try(:id)} ===="
    return @current_order
  end

  def no_permission
    @no_bottom = true
    @westore = true
    render "errors/westore_404"
  end

  def check_user_agent
    unless request.user_agent =~ /MicroMessenger/ || request.user_agent =~ /Windows Phone/
      redirect_to :root
    end
  end

  def no_header
    @no_header = true
  end

end
