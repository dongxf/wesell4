class Westore::OrderConfigOptionsController < ApplicationController
  def price
    @order_config_option = OrderConfigOption.find params[:id]
    render json: {price: @order_config_option.price}, layout: false
  end
end
