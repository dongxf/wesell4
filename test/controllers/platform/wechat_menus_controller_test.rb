require 'test_helper'

class Platform::WechatMenusControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "edit wechat_menu" do
    @user        = users(:one)
    @instance    = instances(:one)
    @wechat_menu = wechat_menus(:one)

    session[:user_id] = @user.id

    get :edit, {instance_id: @instance, id: @wechat_menu.id}
    assert_response :redirect
  end
end
