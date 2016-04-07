class Westore::OrderItemsController < Westore::BaseController
  before_filter :get_order

  def create
    @wesell_item = WesellItem.find params['order_item']['wesell_item_id']
    quantity = params['order_item']['quantity'].to_i

    if params['order_item']['wesell_item_option_ids'].present?
      option_ids = params['order_item'].delete('wesell_item_option_ids')
      option_ids = [option_ids] unless option_ids.is_a? Array
      @order_item = @order.order_item_with_options @wesell_item, quantity, option_ids
    else
      @order_item = @order.order_item @wesell_item, quantity
    end
    if @order_item.save
      @order_item.set_options option_ids if option_ids
      redirect_to edit_westore_order_path(@order)
    else
      @wesell_item = @order_item.wesell_item
      render 'westore/wesell_items/show'
    end
  end

  def edit
    @item = @order.order_items.find params[:id]
    @wesell_item = @item.wesell_item
    render layout: 'wemall'
  end

  def update
    @item = OrderItem.find params[:id]
    @item.update_attributes order_item_params

    redirect_to edit_westore_order_path(@item.order)
  end

  def update_quantity
    @item = @order.order_items.find params[:order_item_id]
    quant = params[:quantity].to_i
    if quant > 0
      @item.quantity += 1
    else
      @item.quantity -= 1
    end
    @item.quantity > 0 ? @item.save : @item.destroy
    @amount = @order.calculate_amount
    @items_count = @order.order_items.count
    if @order.shipping_charge > 0
      flash[:alert] = @order.shipping_charge_tips
    else
      flash[:alert] = nil
    end
  end

private
  def order_item_params
    params.require(:order_item).permit!
  end

  def get_order
    if params[:order_id]
      @order = Order.find params[:order_id]
    else
      @order = current_order
    end
    @store = @order.try(:store)
  end
end
