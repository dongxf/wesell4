#encoding: utf-8
class Printer < ActiveRecord::Base
  belongs_to :store

  validates_presence_of :model, :imei, :copies
  # validates_uniqueness_of :imei #多店共享打印机

  MODEL_TYPE = {
    feyin: '飞印打印机',
    huahao: '华浩打印机'
  }
  symbolize :model, in: MODEL_TYPE.keys, scopes: :shallow, methods: true

  def print info
    case self.model
    when :feyin
      return feyin_print info
    when :huahao
      return huahao_print info
    else
      return false
    end
  end

private

  def feyin_print info
    member_code = ENV['FEIYIN_MEMBER_CODE']
    time_s = Time.now.to_i.to_s
    content = member_code + info + self.imei + time_s + ENV['FEIYIN_API_TOKEN']
    md5_content = Digest::MD5.hexdigest(content)
    data = {
      memberCode: member_code,
      reqTime: time_s,
      securityCode: md5_content,
      deviceNo: self.imei,
      mode: 2,
      msgDetail: info
    }

    begin
      rsp = RestClient.post "http://my.feyin.net/api/sendMsg", data, content_type: 'application/x-www-form-urlencoded'
      # logger.info "======================="
      # logger.info rsp
      # logger.info "======================="
      status="err##{rsp}" if rsp!='0'
      status='ok' if rsp == '0'
    rescue => e
      #status= e.to_s.force_encoding('GBK').encode('UTF-8')
      status= e.to_s
    end
    self.update_attribute :status, status
    return ( status == 'ok' )
  end

  def huahao_print info
    status = "spooling #{Time.now}"

    data = {
      IMEI: self.imei,
      content: info.gsub("\n","%%")
    }

    begin
      rsp = RestClient.get "http://121.199.11.97/manager/ajax/interface/login.jspx?userCode=test&password=123456"
      state_code = JSON.parse(rsp)["stateCode"]
      if state_code == "200"
        cookies = rsp.cookies
        rsp = RestClient.post "http://121.199.11.97/manager/ajax/interface/print.jspx", data, content_type: 'text/plain', cookies: cookies
        state_code = JSON.parse(rsp)["stateCode"]
        status = "err##{state_code}" if state_code != '200'
        status = "ok" if state_code == '200'
      else
        status = "cannot login"
      end
    rescue => e
      #status= e.to_s.force_encoding('GBK').encode('UTF-8')
      #above will caused problem on non-GBK system
      status= e.to_s
    end
    self.update_attribute :status, status
    return ( status == 'okey' )
  end
end
