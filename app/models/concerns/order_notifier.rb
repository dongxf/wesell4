require 'wechat_app'

module OrderNotifier
  extend ActiveSupport::Concern

  def order_submit; notification_to_customer :submit; notification_to_fwdesk :submit end
  def order_accepted; notification_to_customer :accepted end
  def order_shipped; notification_to_customer :shipped end
  def order_rejected; notification_to_customer :rejected end
  def order_canceled; notification_to_customer :canceled end
  def repost_order; notification_to_fwdesk :repost end
  def urge_order; notification_to_fwdesk :urge end

  def notification_to_customer action
    case self.store.stype
    when 'event' 
      form_info = '活动变动通知'
      infos = {
        :submit => '活动报名已提交，工作人员正在处理，请留意稍后的更新推送消息',
        :accepted => '活动报名已成功，如果因故改期或变动，将及时推送提醒消息给您',
        :shipped => '感谢您参加活动，请您在此提供反馈意见帮助我们更好地改进服务',
        :rejected => '非常抱歉，这次活动暂时不能接纳您的报名，如需更多帮助可联系客服',
        :canceled => '您的活动报名已经取消，如需更多帮助可联系客服'
      }
    else
      form_info = '订单变动通知'
      infos = {
        :submit => '感谢提交订单！我们将尽快处理，若有变动或更新将及时推送消息给您',
        :accepted => '订单已接受，我们正在抓紧处理中，若有变动将及时推送消息提醒您',
        :shipped => '您的订单已配送完毕，请确认订单和提供评价帮助我们更好地改进服务',
        :rejected => '非常抱歉，我们因故无法接受您的订单，如需更多帮助可联系客服',
        :canceled => '您的订单已经取消，如需更多帮助可联系客服'
      }
    end
    first_info = infos[action]
    note_info = self.printable_text(false)
    area_info = "#{self.store.name}@#{self.instance.nick} | #{self.store.phone}"
    remark_info = '点击本表单可查看详情'
    text = {
      url: "#{ENV['WESELL_SERVER']}/westore/orders/#{self.id}?customer_cid=#{customer.cid}&instance_id=#{self.instance.id}",
      first: first_info,
      fb_form: form_info,
      fb_note: note_info,
      area: area_info,
      remark: remark_info
    }
    @wechat_app = WechatApp.new self.instance
    @wechat_app.send_template self.instance.template_id, self.customer.openid, text
  end

  def notification_to_fwdesk action
    infos = {:repost => '收到一份配送单', :urge => '顾客催单了', :submit => '收到一份新订单'}
    notes = self.printable_text
    first_info = infos[action]
    form_info = "订单变动通知"
    area_info = "#{self.store.name}@#{self.instance.nick} | #{self.store.phone}"
    remark_info = '点击本表单可查看详情'
    fwdesk = Instance.find_by name: 'fwdesk'
    fwdesk_app = WechatApp.new fwdesk

    them = self.express.binderers if self.express && action == :repost
    them = self.instance.binderers + self.store.binderers if action == :urge || action == :submit
    them ||= []
    them = them.uniq
    them.each do |binderer|
      binder_text = {
        url: "#{ENV['WESELL_SERVER']}/westore/orders/#{self.id}/order_status?customer_cid=#{binderer.cid}",
        first: infos[action],
        fb_form: form_info,
        fb_note: notes,
        area: area_info,
        remark: remark_info
      }
      fwdesk_app.send_template fwdesk.template_id, binderer.openid, binder_text
    end
  end

end
