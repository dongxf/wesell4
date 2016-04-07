require 'test_helper'

class Westore::InstancesControllerTest < ActionController::TestCase
  def setup
    @instance = instances(:one)
    @request.headers['HTTP_USER_AGENT'] = 'MicroMessenger'
  end

  test "show instance" do
    get :show, id: @instance.id
    assert_response :success
  end
end
