require 'test_helper'

class WesellItemTest < ActiveSupport::TestCase
  test "validation" do
    @wesell_item = wesell_items(:one)

    assert @wesell_item.valid?
    assert_equal 'item_1', @wesell_item.name
  end

  test "update_count_cache" do
    @wesell_item = wesell_items(:one)
    @store = @wesell_item.store
    assert_equal 2, @store.wesell_items_count
    wesell_item = WesellItem.create store_id: @store.id,
                                    name: 'new_i',
                                    price: 1,
                                    original_price: 10,
                                    unit_name: '个',
                                    quantity: 0,
                                    status: 0
    assert wesell_item.valid?

    assert_equal 3, @store.reload.wesell_items_count, "@store.wesell_items_count : #{@store.wesell_items_count}"

    wesell_item.destroy
    assert_equal 2, @store.reload.wesell_items_count
  end

  test "correcting order_items unit_price" do
    @wesell_item = wesell_items(:one)
    @wesell_item.update_attributes price: 111
    @order_item = @wesell_item.order_items.first
    assert_equal 111, @order_item.unit_price
  end

  test "human price" do
    wesell_item = wesell_items(:one)

    assert_equal "¥1.0/个", wesell_item.human_price
  end

  test "sold out" do
    @wesell_item = wesell_items(:one)
    @wesell_item.online
    assert_not @wesell_item.sold_out?

    wesell_item = WesellItem.create store_id: @wesell_item.store.id,
                                    name: 'new_i',
                                    price: 1,
                                    original_price: 10,
                                    unit_name: '个',
                                    quantity: 0,
                                    status: 10
    assert wesell_item.sold_out?, "#{wesell_item.quantity}"
  end

  test "copy" do
    @wesell_item = wesell_items(:one)
    @wesell_item_dump = @wesell_item.copy!
    assert_not @wesell_item_dump.valid?

    @wesell_item_dump2 = @wesell_item.copy!(options = { name: "dump_one" })
    assert_equal "dump_one", @wesell_item_dump2.name
    assert_not_equal @wesell_item.id, @wesell_item_dump2.id

    assert_equal @wesell_item.options_groups.count, @wesell_item_dump2.options_groups.count, "#{@wesell_item_dump2.options_groups}"

    origin = @wesell_item.options_groups.first
    dump = @wesell_item_dump2.options_groups.first
    assert_equal origin.name, dump.name
    assert_not_equal origin.id, dump.id
  end

  test "online offline" do
    one = wesell_items(:one)
    two = wesell_items(:two)
    three = wesell_items(:three)
    four = wesell_items(:four)
    five = wesell_items(:five)

    assert_equal WesellItem.online, [two, five, one]
    assert_equal WesellItem.offline, [four]
    assert_equal WesellItem.undeleted, [two, four, five, one]
  end
end
