class Community::BaseController < ApplicationController
  layout 'community'

  #before_filter :parse_query, :filter_customer_cid
  before_filter :parse_query, :authenticate_openid!, :except => [ :select_instance, :echo ]
  before_filter :oauth_38, :only => [ :echo ]
  after_filter :track_logger
  helper_method :current_customer,
                :current_instance

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

  def track_logger; logger.info "---- community base controller: instance s#{session[:instance_id_4]} c#{current_instance.try(:id)}, customer s#{session[:instance_id_4]} c#{current_customer.try(:id)} ----" end

  def parse_query
    instance = Instance.find_by(id: params[:instance_id]) if params[:instance_id]
    instance ||= Village.find_by(id: params[:village_id]).try(:instance) if params[:village_id]
    instance ||= VillageItem.find_by(id: params[:village_item_id]).try(:instance) if params[:village_item_id]
    instance ||= Customer.find_by(id: params[:customer_id]).try(:instance) if params[:customer_id]
    instance ||= Instance.find_by(id: params[:id]) if params[:controller] == 'community/instances' && params[:id].present?
    instance ||= Village.find_by(id: params[:id]).try(:instance) if params[:controller] == 'community/villages' && params[:id].present?
    instance ||= VillageItem.find_by(id: params[:id]).try(:instance) if params[:controller] == 'community/village_items' && params[:id].present?
    instance ||= Customer.find_by(id: params[:id]).try(:instance) if params[:controller] == 'community/customers' && params[:id].present?
    return set_current_instance(instance) if instance.present?
    instance ||= Instance.find_by id: session[:instance_id_4] if session[:instance_id_4]
    if instance.present?
      logger.info("---- recover instance id from session: #{instance.id}----")
      return set_current_instance(instance)
    end
    logger.info("---- community parse error: no instance id available ----")
    redirect_to '/select_instance'
    #/community/customers/xxx/favor will get trouble if xxx is not exists!
    #no_permission if params[:controller] != 'community/tags'
  end

  def oauth_38
    ii=Instance.find 38
    appid = ii.app_id
    appsc = ii.app_secret
    oidkey = "wx_38_oid"
    if session[oidkey].blank?
      code = params[:code]
    # 如果code参数为空，则为认证第一步，重定向到微信认证
      if code.nil?
        logger.info("---- oauth38 step 1 redirect ----")
        redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{request.url}&response_type=code&scope=snsapi_base&state=#{request.url}#wechat_redirect"
      end
      #如果code参数不为空，则认证到第二步，通过code获取openid，并保存到session中
      begin
        url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{appsc}&code=#{code}&grant_type=authorization_code"
        session[oidkey] = JSON.parse(URI.parse(url).read)["openid"]
        logger.info("---- oauth38 step 2, session[#{oidkey}] #{session[oidkey]} ----")
      rescue Exception => e
        logger.info("---- oauth38 step 2 exception: #{e.to_s} using old method ----")
      end
    end
  end

  def authenticate_openid!
    # 判断是否使用oauth
    we_agent = request.user_agent.include?('MicroMessenger') || request.user_agent.include?('Windows Phone')
    return filter_customer_cid if !current_instance.present? || !we_agent || !current_instance.wechat_auth?
    logger.info("---- oauth start: instance #{current_instance} ----")
    # 当session中没有对应instance的openid时，则为非登录状态
    iid = current_instance.id
    appid = current_instance.app_id
    appsc = current_instance.app_secret
    oidkey = "wx_#{iid}_oid"
    if session[oidkey].blank?
      code = params[:code]
    # 如果code参数为空，则为认证第一步，重定向到微信认证
      if code.nil?
        logger.info("---- oauth step 1 redirect ----")
        redirect_to "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{request.url}&response_type=code&scope=snsapi_base&state=#{request.url}#wechat_redirect"
      end
      #如果code参数不为空，则认证到第二步，通过code获取openid，并保存到session中
      begin
        url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{appsc}&code=#{code}&grant_type=authorization_code"
        session[oidkey] = JSON.parse(URI.parse(url).read)["openid"]
        logger.info("---- oauth step 2, session[#{oidkey}] #{session[oidkey]} ----")
      rescue Exception => e
        logger.info("---- oauth step 2 exception: #{e.to_s} using old method ----")
        return filter_customer_cid
      end
    end
    customer = Customer.find_by openid: session[oidkey]
    if !customer.present?
      customer = current_instance.customers.create(subscribed: false, openid: session[oidkey])
      logger.info("---- create new customer: #{customer} ----")
    end
    set_current_customer(customer)
  end

  def filter_customer_cid
    if params[:customer_cid].present?
      customer = Customer.find_by cid: params[:customer_cid]
      if customer.present?; set_current_customer customer else logger.info "---- filter customer failed  #{params[:customer_cid]} ----" end
      redirect_to request.url.gsub(/customer_cid=\w{32}/, '')
    end
  end

  def current_customer
    return @current_customer if @current_customer
    customer = @current_instance.customers.find_by(id: session[:customer_id_4]) if session[:customer_id_4] && @current_instance
    if customer.present?; return set_current_customer(customer) else logger.info "---- restore customer failed 1 #{session[:customer_id_4]} ----" end
    customer = @current_instance.customers.create(subscribed: false) if @current_instance
    if customer.present?; return set_current_customer(customer) else logger.info "---- restore customer failed 2 #{current_instance} ----" end
    logger.info "---- current_customer is nil #{@current_instance.try(:id)} ----" #ss line resturn true
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
    if instance.present?; return set_current_instance(instance) else logger.info "---- restore instance failed 1 #{session[:instance_id_4]} ----" end
    customer = Customer.find_by(id: session[:customer_id_4]) if session[:customer_id_4]
    instance = customer.instance if customer.present?
    if instance.present?; return set_current_instance(instance) else logger.info "---- restore instance failed 2 ----" end
    logger.info "---- current_instance is nil ----"
    @current_instance = nil
  end

  def set_current_instance(instance)
    session[:instance_id_4] = instance.id
    @current_instance = instance
  end

  def no_permission
    render "errors/westore_404"
  end
end
