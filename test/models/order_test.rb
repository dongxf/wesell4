require 'test_helper'
require 'minitest/mock'

class OrderTest < ActiveSupport::TestCase

  test "opening_hours blank" do
    @order = orders(:one)
    assert @order.send(:check_open_status)
  end

  test "put of opening_hours" do
    @order = orders(:one)
    Time.stub :now, Time.parse('2014-05-24 10:00:00') do
      assert @order.send(:check_open_status)
    end
  end

  test "order offline" do
    @order = orders(:one)
    store = @order.store
    store.order_offline = true
    assert @order.send(:check_open_status)
  end


  test "order offline false and opening_hours blank" do
    @order = orders(:one)
    assert @order.send(:check_open_status)
  end

  test "order offline false and out of opening_hours" do
    @order = orders(:three)
    Time.stub :now, Time.parse('2014-05-24 08:00:00') do
      assert_not @order.send(:check_open_status)
    end
  end

  test "block customer" do
    @order = orders(:four)
    assert_equal @order.send(:check_customer), false
  end

  test "calculate amount" do
    @order = orders(:four)
    amount = @order.calculate_amount.to_s
    assert_equal '1.0', amount
  end

  test "calculate amount with shipping_charge" do
    @order = orders(:five)
    amount = @order.calculate_amount.to_s
    assert_equal '11.0', amount
  end

  test "total price" do
    @order = orders(:five)
    price = @order.total_price.to_s
    assert_equal '1.0', price
  end

  test 'waiting payment' do
    @order = orders(:one)
    @order.address = 'haha'
    @order.contact = 'haha'
    @order.phone = '18600000000'
    @order.payment_option = 'wechat'
    assert @order.save
    # begin
    #   @order.waiting_payment!
    # rescue
    #   p @order.message
    # end

    # p @order
    # # p @order.calculate_amount
    # assert_raises AASM::InvalidTransition do
    #   @order.waiting_payment!
    # end
    assert @order.waiting_payment!
    assert_equal 'require_payment', @order.status
  end

  test 'submit with cash payment' do
    @order = orders(:one)
    @order.address = 'haha'
    @order.contact = 'haha'
    @order.phone = '18600000000'
    @order.payment_option = 'cash'
    assert @order.save

    @order.stub :order_submit, true do
      assert @order.submit!
      assert_equal 'sent', @order.status
    end
  end

end
