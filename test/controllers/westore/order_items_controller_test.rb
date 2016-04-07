require 'test_helper'

class Westore::OrdersControllerTest < ActionController::TestCase
  test "edit order item" do
    @instance   = instances(:one)
    @store      = stores(:one)
    @order_item = order_items(:one)

    get :edit, {id: @order_item.id}, {instance_id: @instance.id, store_id: @store.id}

    assert true
  end
end