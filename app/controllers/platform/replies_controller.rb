require 'wechat_app'

class Platform::RepliesController < Platform::BaseController

  def index
    @village = Village.find params[:village_id]
    @instance = @village.instance
    @replies = current_user.replies.page(params[:page])
  end
end
