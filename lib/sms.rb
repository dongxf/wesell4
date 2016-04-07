#encoding: utf-8
require 'rest-client'
require 'open-uri'
require 'timeout'
require 'json'

class Sms
  def self.send_code_with_nick phone, code, nick
    msg = URI::encode "尊敬的会员，您的验证码是#{code}，感谢您使用#{nick}"
    url = "http://www.tui3.com/api/send/?k=d98784f3ec44bb34b93488968bed81d7&r=json&p=1&t=#{phone}&c=#{msg}"
    begin
      rsp = RestClient.get url
      err_code = JSON.parse(rsp)["err_code"]
    rescue => e
      err_code = -9999
    end
    return err_code
  end
  def self.send_code_for_wember phone, code, instance
    nick = instance.nick
    # uu = wember.instance.user
    # result = uu.change_credit "sms by #{wember.class.name} #{wember.id}"
    result = true
    if result
      msg = URI::encode "您的手机验证码是#{code}，感谢您对#{nick}的信任和关照"
      url = "http://www.tui3.com/api/send/?k=d98784f3ec44bb34b93488968bed81d7&r=json&p=1&t=#{phone}&c=#{msg}"
      begin
        rsp = RestClient.get url
        err_code = JSON.parse(rsp)["err_code"]
      rescue => e
        err_code = -9999
      end
      return err_code
    else
      return -9001
    end
  end
end
