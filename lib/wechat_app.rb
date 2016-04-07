class WechatApp
  def initialize instance
    @instance = instance
  end

  def create_remote_menu
    conn = get_conn

    conn.post do |req|
      req.url "/cgi-bin/menu/create?access_token=#{get_access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.parse(build_menus).to_s.gsub('=>', ':')
    end
  end

  def build_menus
    Jbuilder.encode do |json|
      json.set! :button do
        json.array! @instance.wechat_menus do |menu|
          json.name menu.name

          if menu.wechat_sub_menus.present?
            json.set! :sub_button do
              json.array! menu.wechat_sub_menus do |sub_menu|
                json.name sub_menu.name
                json.type sub_menu.menu_type
                if sub_menu.menu_type == 'click'
                  json.key  sub_menu.key
                else
                  json.url  sub_menu.url
                end
              end
            end
          else
            json.type menu.menu_type
            if menu.menu_type == 'click'
              json.key  menu.key
            else
              json.url  menu.url
            end
          end
        end
      end
    end
  end

  def load_default
    @instance.wechat_menus.create menu_type: 'click', name: '开始订购', key: 'stores', sequence: 1
    @instance.wechat_menus.create menu_type: 'click', name: '我的订单', key: 'orders', sequence: 2
    @instance.wechat_menus.create menu_type: 'click', name: '帮助信息', key: 'help', sequence: 3
=begin
    @instance.wechat_menus.create({
      name: '会员服务', sequence: 3,
      wechat_sub_menus_attributes: [{menu_type: 'click', name: '帮助信息', key: 'help'}, {menu_type: 'click', name: '绑定手机', key: 'membership'}]
    })
=end
  end

  def load_remote_menus
    button_arr = get_current_menus['menu']['button']
    @instance.wechat_menus.destroy_all if button_arr.present?
    button_arr.each_with_index do |butn, index|
      if butn['sub_button'].present?
        menu = @instance.wechat_menus.create butn.except('sub_button').merge(sequence: index)
        butn['sub_button'].each_with_index do |sub_menu, index|
          menu.wechat_sub_menus.create sub_menu.except('sub_button', 'type').merge(menu_type: sub_menu['type'], sequence: index)
        end
      else
        menu = @instance.wechat_menus.create butn.except('sub_button', 'type').merge(menu_type: butn['type'], sequence: index)
      end
    end
  end

  def get_qrcode_url spreadable
    ticket = qr_limit_scene_ticket spreadable
    url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{URI.encode(ticket)}"
  end


  def get_current_menus
    url = URI("https://api.weixin.qq.com/cgi-bin/menu/get?access_token=#{get_access_token}")
    response = Faraday.get url
    body = JSON.parse response.body
  end

  def send_cs_message message_json
    conn = get_conn
    resp = conn.post do |req|
      req.url "/cgi-bin/message/custom/send?access_token=#{get_access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = message_json
    end
  end

  def send_template t_id, openid, params={}
    json = {
      touser: openid,
      template_id: t_id,
      url: params[:url],
      topcolor: '#9A1A2E',
      data: {
        first: { value: params[:first], color: '#FF4136' },
        FBForm: { value: params[:fb_form], color: '#000000' },
        FBNote: { value: params[:fb_note], color: '#000000' },
        FBTime: { value: "#{Time.now}", color: '#000000' },
        FBArea: { value: params[:area], color: '#000000' },
        remark: { value: params[:remark], color: '#000000' },
      },
    }.to_json
    conn = get_conn
    resp = conn.post do |req|
      req.url "/cgi-bin/message/template/send?access_token=#{get_access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = json
    end
  end

  def get_user_info user
    url = URI("https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{get_access_token}&openid=#{user.openid}&lang=zh_CN")
    response = Faraday.get url
    body = JSON.parse response.body

    if  body['nickname']
      regex = /[\u{40ee}-\u{9fa5}a-zA-Z]/
      nickname = body['nickname'].scan(regex).join
      user.attributes = ({
        subscribed:  body['subscribe'],
        nickname:   nickname,
        gender:     body['sex'],
        province:   body['province'],
        city:       body['city'],
        country:    body['country'],
        avatar:     body['headimgurl']
      })
      user.save
    else
      return false
    end
  end

  def qr_limit_scene_ticket spreadable
    scene_id = spreadable.is_a?(Integer) ? spreadable : spreadable.get_sceneid
    conn = get_conn
    resp = conn.post do |req|
      req.url "/cgi-bin/qrcode/create?access_token=#{get_access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {action_name: "QR_LIMIT_SCENE", action_info: {scene: {scene_id: scene_id}}}.to_json
    end
    JSON.parse(resp.body)['ticket']
  end

  def get_access_token
    url = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@instance.app_id}&secret=#{@instance.app_secret}")
    response = Faraday.get url
    body = JSON.parse response.body

    return body["access_token"]
  end

  def get_conn
    conn = Faraday.new(:url => "https://api.weixin.qq.com/") do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end
