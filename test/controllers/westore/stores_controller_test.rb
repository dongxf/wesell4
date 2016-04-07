require 'test_helper'

class Westore::StoresControllerTest < ActionController::TestCase
  def setup
    @request.headers['HTTP_USER_AGENT'] = 'MicroMessenger'
  end

  def teardown
     @store = nil
  end

  test "show store with instance_id" do
    @store = stores(:one)
    @instance = instances(:one)

    get :show, {id: @store.id, instance_id: @instance.id}

    assert_response :success

    assert_equal assigns(:store), assigns(:current_store)
    assert_equal assigns(:instance), assigns(:current_instance)
  end

  test "show store without instance_id" do
    @store = stores(:one)
    @instance = instances(:one)

    get :show, { id: @store.id }, { instance_id: @instance.id }

    assert_response :success
    assert_equal assigns(:store), assigns(:current_store)
    assert_equal @instance, assigns(:current_instance)
  end

  test "show store without instance_id in params and session" do
    @store = stores(:one)
    @instance = instances(:one)

    assert_raises ActionView::Template::Error do
      get :show, id: @store.id
    end

    # assert_response :error
    # assert_equal @store, @current_store
    # assert_equal @instance, @current_instance
  end

  test "show store with correct layout & template" do
    @store = stores(:one)
    @instance = instances(:one)

    get :show, {id: @store.id, instance_id: @instance.id}

    assert_template :show
    assert_template layout: 'layouts/westore'

    @store.update_attribute(:template, "wemall")
    get :show, {id: @store.id, instance_id: @instance.id}

    assert_template :mall
    assert_template layout: 'layouts/wemall'
  end

  test "show wemall-store with correct img-count when cookie set" do
    @store = stores(:one)
    @instance = instances(:one)
    @store.update_attribute(:template, "wemall")

    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select 'div.product' do |elements|
      elements.each do |el|
        assert_select el, "img", 1
      end
    end

    cookies[:no_image] = "true"

    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select 'div.product' do |elements|
      elements.each do |el|
        assert_select el, "img", 0
      end
    end

    cookies[:no_image] = "false"

    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select 'div.product' do |elements|
      elements.each do |el|
        assert_select el, "img", 1
      end
    end
  end

  test "show wemall-store with correct images-toggle-link" do
    @store = stores(:one)
    @instance = instances(:one)
    @store.update_attribute(:template, "wemall")

    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select "#no_image", 1

    cookies[:no_image] = "true"
    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select "#with_image", 1

    cookies[:no_image] = "false"
    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select "#no_image", 1
  end

  test "show westore-store with correct items" do
    @store = stores(:one)
    @store_ten = stores(:ten)
    @instance = instances(:one)
    @category = categories(:one)
    @store.update_attribute(:template, "wemall")

    get :show, {id: @store.id, instance_id: @instance.id}
    assert_select "#pInfo > dl", @category.wesell_items.online.count

    get :show, {id: @store_ten.id, instance_id: @instance.id}
    assert_select "#navBar", 0
    assert_select "#pInfo > dl", @store_ten.wesell_items.online.count
  end
end
