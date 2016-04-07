require 'test_helper'

class Westore::OrdersControllerTest < ActionController::TestCase
  def setup
    @request.headers['HTTP_USER_AGENT'] = 'MicroMessenger'
  end

  test "edit order" do
    @instance = instances(:two)
    @store    = stores(:five)
    @customer = customers(:two)

    session[:instance_id_4] = @instance.id
    session[:customer_id_4] = @customer.id

    @order = orders(:six)
    get :edit, id: @order.id
    # @wesell_item = wesell_items(:five)
    # @store = stores(:five)

    # p @store.wesell_items

    # p @wesell_item
    # @store = @order.store
    # @instance = @order.instance
    # @customer = @order.customer

    # p @order.order_items[0]
    # p @order.order_items[0].wesell_item
    # p @order.wesell_items
    # p @order.store
    # p @order.store.wesell_items

    assert_response :success
  end

  test "show order open" do
    @instance = instances(:two)
    @store    = stores(:five)
    @customer = customers(:two)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    @order = orders(:six)

    get :show, id: @order.id
    assert_redirected_to edit_westore_order_path(@order)
  end

  test "show order sent" do
    @instance = instances(:two)
    @store    = stores(:one)
    @customer = customers(:two)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    @order = orders(:two)
    get :show, id: @order.id
    assert_response :success
    assert_not_nil assigns(:order_items)
    assert_not_nil assigns(:order_actions)
  end

  test "alipay" do
    @instance = instances(:two)
    @store    = stores(:five)
    @customer = customers(:two)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    @order = orders(:six)

    put :update, id: @order.id, order: {contact: 'test', phone: '18600000000', address: 'test', payment_option: 'alipay'}
    assert_redirected_to alipay_path(@order)
  end

  test "wechat_pay" do
    @instance = instances(:two)
    @store    = stores(:five)
    @customer = customers(:two)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    @order = orders(:six)

    put :update, id: @order.id, order: {contact: 'test', phone: '18600000000', address: 'test', payment_option: 'wechat'}
    assert_redirected_to payment_path(@order)
  end

  test "active orders" do
    @instance = instances(:one)
    @store    = stores(:one)
    @customer = customers(:one)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    get :index

    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "history orders" do
    @instance = instances(:one)
    @store    = stores(:one)
    @customer = customers(:one)

    session[:instance_id_4] = @instance.id
    session[:store_id_4]    = @store.id
    session[:customer_id_4] = @customer.id

    get :history

    assert_response :success
    assert_not_nil assigns(:orders)
  end
end
