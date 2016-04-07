require 'test_helper'

class InstanceFlowsTest < ActionDispatch::IntegrationTest
  fixtures :instances
  # setup do
  #   Capybara.current_driver = Capybara.javascript_driver # :selenium by default
  # end

  # test 'shows instance kategories' do
  #   # ... this test is run with Selenium ...
  #   @instance = instances(:one)
  #   page = get :show, id: @instance.id
  #   page.must_have_content('Important!')
  # end
end