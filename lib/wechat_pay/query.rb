require 'wechat_pay/signature'
require 'wechat_app'


module WechatPay
  module Query
    def query
      instance = @order.instance
      _timestamp = "#{Time.now.to_i}"
      default_options = {
        appid:        instance.app_id,
        package:      '',
        timestamp:    _timestamp
      }
      package = {
        out_trade_no: "#{@order.id}",
        partner:      instance.partner_id
      }

      package_sign_str = sign_package package.to_param

      signed_package = package.merge(sign: package_sign_str)

      unsigned_str = create_sign_str default_options.merge(appkey: instance.pay_sign_key, package: signed_package.to_param)
      sign_str = sign_pay unsigned_str

      post_data = default_options.merge(package: signed_package.to_param, app_signature: sign_str, sign_method: 'sha1')
      post_json = JSON.generate(post_data)

      conn = Faraday.new(:url => "https://api.weixin.qq.com/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      wechat_app = WechatApp.new instance
      resp = conn.post do |req|
        req.url "/pay/orderquery?access_token=#{wechat_app.get_access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = post_json
      end
      Rails.logger.info resp.body
    end
  end
end
