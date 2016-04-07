#encoding: utf-8
require 'rest-client'
require 'nokogiri'

class LotteryApp
  def initialize customer
    @customer = customer
  end

  def get_lottery lottery
    order_id = lottery.random_unique_id
    user_id = lottery.phone

    last_lottery = Lottery.last

    inside_comm_key = last_lottery.comm_key if last_lottery
    inside_comm_key ||= get_comm_key

    connect_to_yipai user_id, order_id, inside_comm_key
    begin
      lottery_hash = @data[0]
      lottery.update_attributes(game_type: lottery_hash['gameType'].to_i,
                                issue:     lottery_hash['issue'].to_i,
                                seq_no:    lottery_hash['seqNo'].to_i,
                                flowid:    lottery_hash['flowid'],
                                amount:    lottery_hash['amount'].to_i,
                                vote_type: lottery_hash['voteType'].to_i,
                                vote_nums: lottery_hash['voteNums'],
                                multi:     lottery_hash['multi'].to_i,
                                comm_key:  inside_comm_key)
      return lottery
    rescue Exception => e
      lottery.destroy
      p e.message
    end
  end

  def update_mobile lottery, mobile
    user_id = @customer.id.to_s
    body = user_id + CHANNEL_CODE + mobile
    comm_sign = encrypt body, inside_comm_key
    url = BASE_URL + "updateMobile?id=#{CHANNEL_CODE}&userID=#{user_id}&mobile=#{mobile}&sign=#{comm_sign}"
    Rails.logger.info url

    resp = RestClient.get url
    xml = Nokogiri::XML(resp)
    message = JSON.parse xml.at_css('return').children[0].text
    Rails.logger.info message

    @error_code = message['errorCode']
    @times ||= 0
    @times += 1
    update_mobile(lottery, mobile) if @error_code == '9007' && @times < 3

    @datas = message['datas']
  end

  # 获取某一期的中奖记录列表
  def get_award_info lottery
    issue = lottery.issue
    last_lottery = Lottery.last
    inside_comm_key = last_lottery.comm_key if last_lottery
    inside_comm_key = get_comm_key if inside_comm_key.blank? || @error_code == '9007'

    body = issue.to_s + CHANNEL_CODE
    comm_sign = encrypt body, inside_comm_key
    url = BASE_URL + "getAwardInfo?id=#{CHANNEL_CODE}&issue=#{issue}&sign=#{comm_sign}"
    Rails.logger.info url

    resp = RestClient.get url
    xml = Nokogiri::XML(resp)
    @message = JSON.parse xml.at_css('return').children[0].text
    Rails.logger.info @message

    @error_code = @message['errorCode']
    @times ||= 0
    @times += 1
    get_award_info(lottery) if @error_code == '9007' && @times < 3

    @datas = @message['datas']
  end

  # 获取用户的彩票列表
  # -1, 所有彩票
  # 0,  待开奖
  # 1,  未中奖
  # 2,  已中奖

  def get_lottery_records type, page = 1
    page_size = 10
    last_lottery = Lottery.last
    inside_comm_key = last_lottery.comm_key if last_lottery
    inside_comm_key = get_comm_key if inside_comm_key.blank? || @error_code == '9007'

    phone = @customer.phone
    phone ||= @customer.lotteries.first.phone
    body = phone + CHANNEL_CODE + type.to_s + page.to_s + page_size.to_s
    comm_sign = encrypt body, inside_comm_key

    url = BASE_URL + "getLotteryListByUserID?id=#{CHANNEL_CODE}&userID=#{phone}&type=#{type}&page=#{page}&pageSize=#{page_size}&sign=#{comm_sign}"
    Rails.logger.info url

    resp = RestClient.get url
    xml = Nokogiri::XML(resp)
    @message = JSON.parse xml.at_css('return').children[0].text
    Rails.logger.info @message

    @error_code = @message['errorCode']
    @times ||= 0
    @times += 1
    get_lottery_records(type) if @error_code == '9007' && @times < 3

    @datas = @message['datas']
  end

  def get_account_info

  end

private

  def trans_key key
    url = BASE_URL + "transSignKey?id=#{CHANNEL_CODE}&key=#{key}"
    p url
    resp = RestClient.get url
    @xml = Nokogiri::XML(resp)
    message = @xml.at_css('return').children[0].text

    transed_key = JSON.parse(message)['key']
  end

  def get_secure_key sign
    url = BASE_URL + "getSecuretKeyByID?id=#{CHANNEL_CODE}&sign=#{sign}"
    p url
    resp = RestClient.get url
    @xml = Nokogiri::XML(resp)
    message = @xml.at_css('return').children[0].text

    transed_key = JSON.parse(message)['key']
  end

  def get_comm_key
    trans_init_key = trans_key INIT_SECRET
    sign = encrypt CHANNEL_CODE, trans_init_key

    securet_key = get_secure_key sign

    inside_key = decrypt securet_key, trans_init_key
    trans_inside_key = trans_key inside_key
    return trans_inside_key
  end


  def encrypt content, key
    cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    cipher.encrypt

    cipher.key = [key].pack 'H*'

    encrypted = cipher.update(content) + cipher.final

    return  encrypted.unpack('H*')[0].upcase
  end

  def decrypt(encrypted, key)
    decipher = OpenSSL::Cipher::AES.new(128, :ECB)
    decipher.decrypt
    decipher.padding = 1

    decipher.key = [key].pack 'H*'

    plain = decipher.update([encrypted].pack('H*')) + decipher.final

    return plain
  end

  def connect_to_yipai user_id, order_id, inside_comm_key
    amount = 20
    num = 1
    body = user_id.to_s + CHANNEL_CODE + order_id.to_s + amount.to_s + num.to_s;

    comm_sign = encrypt body, inside_comm_key

    url = BASE_URL + "getLottery?id=#{CHANNEL_CODE}&userID=#{user_id}&amount=#{amount}&num=#{num}&orderID=#{order_id}&sign=#{comm_sign}"
    Rails.logger.info url

    resp = RestClient.get url
    xml = Nokogiri::XML(resp)

    message = JSON.parse xml.at_css('return').children[0].text
    Rails.logger.info message

    @data = message['datas']
    @error_code = message['errorCode']
    @times ||= 0
    @times += 1

    connect_to_yipai(user_id, order_id, get_comm_key) if @error_code == '9007' && @times < 3
  end
end