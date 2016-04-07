require 'faraday'
require 'nokogiri'
require 'wechat_pay/signature'
require 'wechat_pay/shipping'
require 'wechat_pay/query'

module WechatPay
  class Util
    include WechatPay::Signature
    include WechatPay::Shipping
    include WechatPay::Query

    def initialize order
      @order = order
    end

    def get_package settings
      encoded_params_str = default_package_params.merge(settings).to_param
      decoded_params_str = URI.decode(encoded_params_str).gsub('+', ' ')
      sign_str = sign_package decoded_params_str
      package = encoded_params_str << "&sign=#{sign_str}"
      package.gsub('+', '%20')
    end

    def get_pay_params package
      pay_params = {
        appid:     @order.instance.app_id,
        appkey:    @order.instance.pay_sign_key,
        noncestr:  @order.oid,
        package:   package,
        timestamp: @order.timestamp
      }
      URI.decode(pay_params.to_param).gsub('+', '%20')
    end

    def ship!
      ship
    end

    def query!
      query
    end

    def refund

    end

    def complain

    end

    def warning

    end


    ##################################
    # sign_type:          签名类型，默认：MD5
    # service_version:    版本号，默认：1.0
    # input_charset:      字符编码，默认：GBK
    # sign:               签名
    # sign_key_index:     多密钥支持的密钥序号，默认1
    # bank_type:          银行类型，默认：Default，跳转到财付通支付中心
    # body:               商品描述
    # attach:             附加数据，原样返回
    # return_url:         交易完成后跳转的URL，需给绝对路径，255字符内
    # notify_url:         接收财付通通知的URL，需给绝对路径，255字符内
    # buyer_id:           买方的财付通账户(QQ 或EMAIL)
    # partner:            商户号
    # out_trade_no:       商户系统内部的订单号,32个字符内
    # total_fee:          订单总金额，单位为分
    # fee_type:           默认值是1，人民币
    # spbill_create_ip:   订单生成的机器IP，指用户浏览器端IP，不是商户服务器IP
    # time_start:
    # time_expire:
    # transport_fee:
    # product_fee:
    # goods_tag:
    #################################
    def default_package_params
      {
        bank_type:          'WX',
        input_charset:      'UTF-8',
        body:               @order.digest,
        partner:            @order.instance.partner_id, #商户号
        out_trade_no:       @order.id,
        total_fee:          @order.total_fee,
        fee_type:           1
      }
    end


  end
end
