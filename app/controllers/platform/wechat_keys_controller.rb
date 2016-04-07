class Platform::WechatKeysController < Platform::BaseController
  before_filter :get_instance

  def index
    @wechat_keys = @instance.wechat_keys.page params[:page]
  end

  def new
    @wechat_key = @instance.wechat_keys.build
  end

  def create
    create! { platform_instance_wechat_keys_path(@instance) }
  end

  def update
    update! { platform_instance_wechat_keys_path(@instance) }
  end

  def destroy
    destroy! { platform_instance_wechat_keys_path(@instance) }
  end


private

  def wechat_key_params
    params.required(:wechat_key).permit!
  end

  def get_instance
    @instance = Instance.find params[:instance_id]
  end
end
