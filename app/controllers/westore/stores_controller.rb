class Westore::StoresController < Westore::BaseController
  before_filter :track_scene, only: [:show]

  def index
    @stores = current_instance.localized_stores(current_instance.stores, current_customer)
  end

  def entry
    @store = Store.find params[:id]
  end

  def show
    @active_link = :guides
    if params[:instance_id].present?
      @instance = Instance.find params[:instance_id]
      set_current_instance @instance
    end

    @store = current_instance.stores.find(params[:id])
    logger.info "=========#{@store.id}================="
    # set_current_store @store
    logger.info "=====set here=session[:store_id_4]=is===#{@store.id}================="

    @no_bottom = true if @store.link.present?
    @order = current_order
    @categories = @store.categories.active
    if @store.template == "wemall"
      @products = @store.wesell_items.online.order('total_sold desc').page(params[:page]).per(9)
      respond_to do |format|
        format.html { render :mall, layout: "wemall" }
        format.js
      end
    elsif @store.template == "westore"
      if @categories.present?
        @category = @categories.first
        @products = @category.wesell_items.online
      else
        @products = @store.wesell_items.online
      end
    end
  end

  def about
    @active_link = :store
    @instance = Instance.find params[:instance_id]
    @store = Store.find(params[:id])
    @categories = @store.categories.active
    render layout: "wemall"
  end

  def search
    @active_link = :guides
    if params[:instance_id].present?
      @instance = Instance.find params[:instance_id]
      set_current_instance @instance
    end

    @store = current_instance.stores.find(params[:id])
    set_current_store @store

    @search = @store.wesell_items.solr_search do
      fulltext params[:product_search][:q], highlight: true
      with :store_id, params[:id]
      order_by :total_sold, :desc
      paginate(:page => params[:page] || 1)
    end

    @q = params[:product_search][:q]
    @products = @search.results
    respond_to do |format|
      format.html { render 'westore/wesell_items/index', layout: "wemall" }
      format.js { render 'westore/stores/show'}
    end
  end

  def add_item
    @order = current_order
    @product = WesellItem.find params[:product_id]
    unless @product.store == @order.store
      set_current_store @product.store
      @order = current_order
      # reset current_store & current_order when using go-back-button
    end
    # if params[:quantity].to_i > 0
    #   @item = @order.order_item @product, +1
    # else
    #   @item = @order.order_item @product, -1
    # end
    quantity = params[:quantity].to_i
    @item = @order.order_item2 @product, quantity
    render json: {code: 0, message: '', result: {}}
  end

private

  def track_scene
    if params[:sceneid].present?
      session[:sceneid] = params[:sceneid]
    else
      session.delete(:sceneid)
    end
  end
end
