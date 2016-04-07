class Westore::WesellItemsController < Westore::BaseController
  layout "wemall", only: [:show, :index, :checkin, :add_info]

  def index
    @store = current_instance.stores.find(params[:store_id])
    set_current_store @store

    @categories = @store.categories.active
    @products = @store.wesell_items.online.page(params[:page]).per(9)

    respond_to do |format|
      format.html
      format.js { render 'westore/stores/show'}
    end
  end

  def show
    @wesell_item = WesellItem.find params[:id]
    @wesell_item_options = @wesell_item.wesell_item_options
    @comments = @wesell_item.comments.arrange_as_array(order: 'created_at DESC')
    @comments =  Kaminari.paginate_array(@comments).page(params[:page]).per(10)
    @store = @wesell_item.store
    set_current_store @store
    @order_item = current_order.order_items.build(wesell_item_id: @wesell_item.id, quantity: 1)
  end

  def checkin
    @no_westore_footer = true
    @wesell_item = WesellItem.find params[:id]
    @checked_customer_ids=CustomerEvent.where(target_type: 'WesellItemId', target_id: @wesell_item.id, event_type: 'checkin_wesell_item').pluck(:customer_id).uniq
    @checked_customers=Customer.where(id: @checked_customer_ids)
    @buyers = @wesell_item.buyers
  end

  def add_info
    @no_westore_footer = true
    @wesell_item = WesellItem.find params[:id]
    @buyers = @wesell_item.buyers
  end

  def buy
    @wesell_item = WesellItem.find params[:id]
    set_current_store @wesell_item.store
    @order_item = current_order.order_items.find_or_initialize_by(wesell_item_id: @wesell_item.id)
    @order_item.quantity += 1
    if @order_item.save
      redirect_to edit_westore_order_path(current_order)
    else
      redirect_to westore_wesell_item_path(@wesell_item)
    end
  end
end
