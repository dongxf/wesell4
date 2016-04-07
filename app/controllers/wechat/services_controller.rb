require 'wechat_app'

class Wechat::ServicesController < Wechat::BaseController
  include Wechat::BindProcessor

  before_filter :parse_xml, :check_wechat_user, :check_location, only: [:create]

  def show
    @instance.api_echoed += 1
    @instance.save
    render text: params[:echostr]
  end

  def create
    return if performed?
    @customer.set_default_village
    case @xml.MsgType.downcase
    when 'event'
      return event_message
    when 'text'
      return text_message
    when 'location' # 用户输入地理位置
      return rend_location_message
    else
      render 'help' and return
    end
  end

private

  def parse_xml
    if params[:xml]
      @xml = OpenStruct.new params[:xml]
    else
      logger.info "parse_xml error: #{params}"
      render "wechat/services/error", layout: false
    end
  end

  def check_wechat_user
    @customer = Customer.find_or_create_by openid: @xml.FromUserName, instance_id: @instance.id

    @customer.visit_count ||= 0
    @customer.visit_count += 1

    old_current, new_current   = @customer.current_visit_at, Time.now.utc
    @customer.last_visit_at    = old_current || new_current
    @customer.current_visit_at = new_current

    old_current, new_current   = @customer.current_visit_ip, request.remote_ip
    @customer.last_visit_ip    = old_current || new_current
    @customer.current_visit_ip = new_current
    @customer.default_village_id = @instance.villages.first.id if @customer.default_village_id.blank? && @instance.villages.size > 0

    @customer.save
  end

  def check_location
    return unless @instance.check_location
    unless @xml.MsgType.downcase == 'location' || (@xml.MsgType == 'event' && @xml.Event.downcase == 'location')
      render 'wechat/services/location_tips' and return unless @customer.located?
    end
  end

  #事件处理
  def event_message
    case @xml.Event
    when 'subscribe' # 新关注用户
      @customer.subscribe
      if @instance.app_available?
        wechat_app = WechatApp.new @instance
        wechat_app.get_user_info(@customer) # if @customer.gender.blank?
      end
      return subscribe_event
    when 'unsubscribe' # 取消关注用户
      @customer.unsubscribe
    when 'LOCATION' # 当用户允许位置获取，微信系统每5秒上报一次地理位置
      return location_event
    when 'CLICK' # 针对有自定义菜单的公众号
      return click_event
    when 'SCAN'
      @sceneid = @xml.EventKey
      scan_secenid_reg @customer, @sceneid
      return rend_scene @sceneid
    when 'TEMPLATESENDJOBFINISH'  #发送模板消息返回
      reply = Reply.find_by msg_id: @xml.MsgID
      reply.update! status: @xml.Status if reply
    end
  end

  # 针对订阅号，没有自定义菜单，只能通过输入信息交互
  def text_message
    case @xml.Content.downcase
    when '?','？','h','ｈ','Ｈ'
      render "help"
    when 'o','ｏ','Ｏ'
      @orders = @customer.orders.active.limit(8).includes(:store)
      render "wechat/services/events/orders"
    when 'i','ｉ','Ｉ'
      render "wechat/services/events/instance"
    when 'k','ｋ','Ｋ'
      @kategories = @instance.valid_kategories.limit(8)
      render "wechat/services/events/kategories"
    when 's','ｓ','Ｓ','m','ｍ','Ｍ'
      @stores = @instance.localized_stores(@instance.stores, @customer).first(8)
      render "wechat/services/events/stores"
    when 'loc', '位置'
      @loc = @customer.location.present? ? @customer.location : @customer.build_location
      render "loc"
    when '绑定手机','bind','绑定'
      render "wechat/services/events/membership"
    when 'wxpay'
      render 'wxpay'
    when 'manager'
      vi_ids =  Binder.where("target_type = ? and customer_id = ?", "VillageItem", @customer.id).pluck(:target_id)
      @village_items = VillageItem.find(vi_ids)
      render "wechat/services/events/manager"
    when /绑定店铺/, /绑定公众号/, /松绑店铺/, /松绑公众号/, /绑定黄页/, /松绑黄页/, /绑定配送/, /松绑配送/
      process_binding @xml.Content if @instance.name == 'fwdesk'
    when /关联配送/
      if @instance.name == 'fwdesk'
        content = @xml.Content
        key, s_code, e_id = content.split(' ')
        @store = Store.find_by invite_code: s_code
        @express = Express.find e_id
        @store.expresses << @express if @express && @store
        render 'wechat/services/binds/store_express'
      end
    when /shequ/, /社区/, /community/, /黄页/, /小区黄页/, /祈福黄页/ #返回黄页
      @villages = @instance.villages.first(7)# if @instance.villages.empty?
      @party = @instance.stores.where(name: "主题聚会").first
      render "wechat/services/events/community"
    when 'hurry_up', 'hurryup', 'hurry'
      @tip = ''
      @order = @customer.orders.hurriable.first
      @tip += "#{@order.hurry_feedback}\n" if @order && @order.hurriable?
      server_url = ENV['WESELL_SERVER']
      orders_link = "<a href='#{server_url}/westore/orders?customer_cid=#{@customer.cid}'>[此处查看]</a>"
      @tip += "没有应催促订单\n" if @order.blank?
      @tip += "点击#{orders_link}全部订单\n" if @customer.orders.size > 0
      @tip += "人工服务请致电#{@customer.instance.phone}\n"
      render "wechat/services/events/tip"
    else
      @wechat_key = @instance.wechat_keys.where(key: @xml.Content).first
      if @wechat_key.present?
        render "wechat/services/events/custom_key"
      elsif !@instance.handle_missing_keys?
        render "wechat/services/events/cs"
      else
        render "help"
      end
    end
  end

  #发送地理位置信息
  def rend_location_message
    @location = @customer.location.present? ? @customer.location : @customer.build_location
    @location.update_attributes latitude: @xml.Location_X, longitude: @xml.Location_Y, address: @xml.Label
    @stores = @instance.localized_stores(@instance.stores, @customer).first(8)
    render "wechat/services/events/stores"
  end

  #微信地理位置上报事件
  def location_event
    @location = @customer.location.present? ? @customer.location : @customer.build_location
    @location.update_attributes latitude: @xml.Latitude, longitude: @xml.Longitude, address: nil
    render nothing: true and return
  end

  def scan_secenid_reg customer, sceneid
    CustomerEvent.create(customer_id: customer.id, target_id: sceneid, target_type: 'SceneId', duration:Time.now,frequency:'real_time',event_type:'scan_sceneid',event_count:1,name:'customer_scan_sceneid',url: '',comment:'')
  end

  #关注事件
  def subscribe_event
    if @xml.EventKey.present?
      @sceneid = @xml.EventKey.split('_')[1]
      if @sceneid =~ /\A\d+\Z/
        @customer.update_column :from_sceneid, @sceneid
        scan_secenid_reg @customer, @sceneid
        return rend_scene @sceneid
      end
    end
    return rend_subscribe
  end

  def rend_subscribe
    # and return can be removed later? and else should be handled later
    case @instance.subscribe_reply
    when 'stores'
      @stores = @instance.localized_stores(@instance.stores.opening, @customer).first(8)
      render "wechat/services/events/stores" and return
    when 'kategories'
      @kategories = @instance.valid_kategories.limit(8)
      if @kategories.present?
        render "wechat/services/events/kategories" and return
      else
        @stores = @instance.localized_stores(@instance.stores.opening, @customer).first(8)
        render "wechat/services/events/stores" and return
      end
    when 'instance'
      render "wechat/services/events/instance" and return
    when 'store'
      @store = @instance.stores.online.first
      render "wechat/services/events/store" and return
    when /shequ/, /社区/, /community/, /黄页/, /小区黄页/, /祈福黄页/ #返回黄页
      @villages = @instance.villages.first(7)# if @instance.villages.empty?
      @party = @instance.stores.where(name: "主题聚会").first
      render "wechat/services/events/community" and return
    end
  end
  #自定义菜单事件
  def click_event
    event_key = @xml.EventKey
    case event_key
    when 'orders', 'ORDER_MENU' #订单信息，当前订单，催单
      @orders = @customer.orders.history.limit(8).includes(:store)
      render "wechat/services/events/orders"
    when 'stores', 'MAIN_MENU' #店铺列表
      @stores = @instance.localized_stores(@instance.stores, @customer).first(8)
      render "wechat/services/events/stores"
    when 'wesell_items' #显示特定店的商品列表, 用子菜单配置的URL保存店铺ID
      wm = @instance.wechat_sub_menus.find_by_key 'wesell_items'
      @store = Store.find wm.url if wm && wm.url
      @store ||= @instance.stores.first
      @wesell_items = @store.wesell_items[0..7] if @store
      render "wechat/services/events/wesell_items"
    when 'kategories' #店铺分类
      @kategories = @instance.valid_kategories.limit(8)
      if @kategories.present?
        render "wechat/services/events/kategories"
      else
        @stores = @instance.localized_stores(@instance.stores, @customer).first(8)
        render "wechat/services/events/stores"
      end
    when 'instance', 'CUST_NEWS_1' #公众号介绍
      render "wechat/services/events/instance"
    when 'membership', 'WEMBER_MENU', 'WEMBER_INFO', 'BIND_WKEY' #会员信息
      render "wechat/services/events/membership"
    when 'help', 'CUST_NEWS_2' #帮助信息
      render "wechat/services/events/help"
    when 'cs'   #多客服
      render "wechat/services/events/cs_hint"
    when 'community' #返回黄页
      @villages = @instance.villages.first(7)# if @instance.villages.empty?
      @party = @instance.stores.where(name: "主题聚会").first
      render "wechat/services/events/community"
    when 'manager'   #管理黄页条目
      vi_ids =  Binder.where("target_type = ? and customer_id = ?", "VillageItem", @customer.id).pluck(:target_id)
      @village_items = VillageItem.find(vi_ids)
      render "wechat/services/events/manager"
    when 'hurry_up', 'hurryup', 'hurry'
      @tip = ''
      @order = @customer.orders.hurriable.first
      @tip += "#{@order.hurry_feedback}\n" if @order && @order.hurriable?
      server_url = ENV['WESELL_SERVER']
      orders_link = "<a href='#{server_url}/westore/orders?customer_cid=#{@customer.cid}'>[此处查看]</a>"
      @tip += "没有应催促订单\n" if @order.blank?
      @tip += "点击#{orders_link}全部订单\n" if @customer.orders.size > 0
      @tip += "人工服务请致电#{@customer.instance.phone}\n"
      render "wechat/services/events/tip"
    else
      @wechat_key = @instance.wechat_keys.where(key: event_key).first
      render "wechat/services/events/custom_key"
    end
  end

  def rend_scene sceneid
    event_key = sceneid.to_i
    return rend_subscribe if event_key <= 100

    op = @instance.operations.find_by(sceneid: event_key)
    if op.present?
      @store = op.store
      @customer.set_default_instance @instance
      @village_item = VillageItem.find_by(store_id: @store.id)
    end

    @village_item ||= @instance.village_items.find_by(sceneid: event_key)
    if @village_item
      unless @village_item.favor_by? @customer
        @village_item.favor_by @customer
        @village_item.reload
      end
    end

    render "wechat/services/events/store" and return if @store

    @village = Village.find(@customer.default_village_id) if @customer.default_village_id
    @village ||= @village_item.villages.first if @village_item 
    render "wechat/services/events/village_item" and return if @village_item

    rend_subscribe

  end

end
