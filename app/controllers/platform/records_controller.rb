require 'wechat_app'
class Platform::RecordsController < Platform::BaseController
  def reply
    @record = Record.find params[:id]
    @customer = @record.customer
    @instance = @record.instance

    wechat_app = WechatApp.new @instance
    resp = wechat_app.send_template @instance.template_id, @customer.openid, params[:reply]
    msg_id = JSON.parse(resp.body)["msgid"]

    Reply.create!  replyable_type: "Record",
                  replyable_id: @record.id,
                  hash_content: params[:reply].inspect,
                  user_id: current_user.id,
                  msg_id:  msg_id.to_s
  end
end
