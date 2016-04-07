require 'test_helper'

class CustomerTest < ActiveSupport::TestCase
  test "register member" do
    order = orders(:one)
    customer = order.customer

    member = customer.register_member order

    assert_not member.new_record?
    assert_equal 'contact_one', member.name
  end
end
