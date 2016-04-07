require 'digest'


module WechatPay
  module Signature
    def sign_package params_str
      Digest::MD5.hexdigest(params_str+"&key=#{@order.instance.partner_key}").upcase
    end

    def sign_pay params_str
      Digest::SHA1.hexdigest params_str
    end

    def create_sign_str options={}, sort=true
      unsigned_str = ''
      if sort
        unsigned_params = options.sort
      end
      unsigned_params.each do |key,value|
        unsigned_str += (key.to_s + '=' + value.to_s + '&')
      end
      unsigned_str = unsigned_str[0, unsigned_str.length - 1]
    end
  end
end