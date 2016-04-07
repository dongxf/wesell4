require 'wechat_app'
class Platform::CommentsController < Platform::BaseController
  def reply
    @comment = Comment.find params[:id]
    @customer = @comment.customer
    @instance = @comment.commentable.instance

    wechat_app = WechatApp.new @instance
    resp = wechat_app.send_template @instance.template_id, @customer.openid, params[:reply]
    msg_id = JSON.parse(resp.body)["msgid"]

    Reply.create!  replyable_type: "Comment",
                  replyable_id: @comment.id,
                  hash_content: params[:reply].inspect,
                  user_id: current_user.id,
                  msg_id:  msg_id.to_s
  end

  def destroy
    @comment = Comment.find params[:id]
    @village = Village.find params[:village_id]
    if @comment.destroy
      redirect_to   comments_platform_village_path(@village)
    end
  end
end
