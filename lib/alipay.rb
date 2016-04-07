require 'builder'
require 'faraday'

module Alipay
  class Util
    include Rails.application.routes.url_helpers

    def initialize order
      @order = order
    end

    def hash_to_query options={}, sort=true
      unsigned_str = ''

      unsigned_params = sort ? options.sort : options

      unsigned_params.each do |key,value|
        unsigned_str += (key.to_s + '=' + value.to_s + '&')
      end
      unsigned_str = unsigned_str[0, unsigned_str.length - 1]
    end

    def sign hash, sort=true
      unsigned_str = hash_to_query hash, sort
      Digest::MD5.hexdigest unsigned_str + "#{ENV['ALIPAY_KEY']}"
    end

    def get_token
      param = gen_trade_params
      auth_query = hash_to_query param.merge(sign: sign(param))

      resp = Faraday.get ENV['ALIPAY_GATEWAY'] + '?' + auth_query
      resp_hash = Rack::Utils.parse_nested_query resp.body
      if resp_hash["res_data"]
        xml = Nokogiri::XML resp_hash["res_data"]
        request_token = xml.at_css("request_token").content
      end
      Rails.logger.info request_token
      request_token
    end

    def execute_url
      request_token = get_token
      if request_token.present?
        sign_str = sign gen_auth_params(request_token)
        execute_query = hash_to_query gen_auth_params(request_token).merge(sign: sign_str)
        return ENV['ALIPAY_GATEWAY'] + '?' + execute_query
      end
    end

  protected

    def build_trade_xml
      mhost = 'fooways.com'
      # mhost = '120.85.69.111:3000'
      xm = Builder::XmlMarkup.new
      xm.direct_trade_create_req{
        xm.subject(@order.payment_subject)
        xm.out_trade_no(@order.id)
        xm.total_fee(@order.real_pay)
        xm.seller_account_name('payment@fooways.com')
        xm.call_back_url alipay_callback_url(@order, host: mhost)
        xm.notify_url alipay_notify_url(@order, host: mhost)
        # xm.out_user('test')
        xm.merchant_url westore_store_url(@order.store, instance_id: @order.instance_id, host: mhost)
        # xm.pay_expire('test')
      }
    end

    def build_auth_xml token
      xm = Builder::XmlMarkup.new
      xm.auth_and_execute_req{
        xm.request_token(token)
      }
    end

    def gen_trade_params
      param = {
        req_data: build_trade_xml,
        service: ENV['ALIPAY_AUTH'],
        sec_id: 'MD5',
        partner: ENV['ALIPAY_ID'],
        req_id: "#{Time.current.to_i}",
        format: 'xml',
        v: '2.0'
      }
    end

    def gen_auth_params token
      param = {
        req_data: build_auth_xml(token),
        service: ENV['ALIPAY_EXECUTE'],
        sec_id: 'MD5',
        partner: ENV['ALIPAY_ID'],
        format: 'xml',
        v: '2.0'
      }
    end
  end
end