require 'wechat_app'

class Platform::WechatMenusController < Platform::BaseController
  before_filter :get_wechat_app

  def index
    @wechat_menus = @instance.wechat_menus
  end

  def new
    @wechat_menu = @instance.wechat_menus.build
  end

  def create
    create! do |success, failure|
      success.html { redirect_to platform_instance_wechat_menus_path(@instance) }
      failure.html { render :new }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to platform_instance_wechat_menus_path(@instance) }
      failure.html { render :edit }
    end
  end

  def destroy
    destroy! { redirect_to platform_instance_wechat_menus_path(@instance) and return}
  end

  def load_default
    @wechat_app.load_default
    redirect_to platform_instance_wechat_menus_path(@instance)
  end

  def load_remote
    flash[:notice] = '账号类型无效' if @wechat_app.blank?
    flash[:notice] = '加载成功' if @wechat_app && @wechat_app.load_remote_menus
    redirect_to action: :index
  end

  def sync
    response = @wechat_app.create_remote_menu
    body = JSON.parse response.body

    if body['errcode'] == 0
      flash[:notice] = '同步成功'
    else
      flash[:alert] = "#{body['errcode']}, #{body['errmsg']}"
    end

    redirect_to action: :index
  end

private

  def wechat_menu_params
    params.require(:wechat_menu).permit!
  end

  def get_wechat_app
    @instance = Instance.find params[:instance_id]
    @wechat_app = WechatApp.new @instance
  end
end
