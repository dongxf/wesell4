class TestController < ApplicationController
  layout false

  def wx_pay
    render 'wx_pay'
  end
  
end
