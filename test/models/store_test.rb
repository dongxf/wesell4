require 'test_helper'
require 'minitest/mock'

class StoreTest < ActiveSupport::TestCase
  test "open store" do
    @store = stores(:one)
    assert @store.is_open?
  end

  test "close store" do
    @store = stores(:four)
    assert_not @store.is_open?
  end

  test "in openning_hours" do
    @store = stores(:two)

    Time.stub :now, Time.parse('2014-05-24 10:00:00') do
      assert @store.is_open?
    end
  end

  test "out openning_hours" do
    @store = stores(:two)

    Time.stub :now, Time.parse('2014-05-24 08:00:00') do
      assert_not @store.is_open?
    end
  end

  test "gen_invite_code" do
    @store = Store.create name: "s1",
                          description: "fff",
                          phone: "18600000001",
                          email: "one@stores.com",
                          street: "祈福新村126号"
    assert @store.valid?
    assert_equal 8, @store.invite_code.length
  end

  test "popular wesell_item" do
    @store = stores(:one)
    @wesell_item = @store.wesell_items.create  store: @store,
                                name: "new",
                                description: "==",
                                price: 1.00,
                                original_price: 1.99,
                                unit_name: "个",
                                quantity: 1,
                                status: 0
    @wesell_item.update_attribute(:total_sold, 10)
    assert_equal @wesell_item, @store.popular
  end
end
