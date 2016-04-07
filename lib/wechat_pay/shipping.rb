require 'wechat_pay/signature'
require 'wechat_app'


module WechatPay
  module Shipping
    def ship options={}
      instance = @order.instance
      default_options = {
        appid:             instance.app_id,
        openid:            @order.customer.openid,
        transid:           @order.transid,
        out_trade_no:      @order.id,
        deliver_timestamp: "#{@order.shipped_at.to_i}",
        deliver_status:    "1",
        deliver_msg:       "ok"
      }

      unsigned_str = create_sign_str default_options.merge(appkey: instance.pay_sign_key)
      sign_str = sign_pay unsigned_str

      conn = Faraday.new(:url => "https://api.weixin.qq.com/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      wechat_app = WechatApp.new instance
      resp = conn.post do |req|
        req.url "/pay/delivernotify?access_token=#{wechat_app.get_access_token}"
        req.headers['Content-Type'] = 'application/json'
        req.body = default_options.merge(options).merge(app_signature: sign_str, sign_method: "sha1").to_json
      end
      Rails.logger.info resp.body
    end
  end
end
