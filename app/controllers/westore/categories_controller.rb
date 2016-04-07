class Westore::CategoriesController < Westore::BaseController
  def show
    @category = Category.find params[:id] if params[:id]
    @store = @category.store
    @order = current_order
    if @category
      @products = @category.wesell_items.online
    elsif @store
      @products = @store.other_wesell_items.online
    end
    if @store.template == "wemall"
      @products = @products.page params[:page]
      respond_to do |format|
        format.html { render 'westore/wesell_items/index', layout: "wemall" }
        format.js { render 'westore/stores/show'}
      end
    else
      render '_products_list', layout: false
    end
  end

  def mall
    @category = Category.find params[:category_id] if params[:category_id]
    @store = Store.find params[:store_id] if params[:store_id]
    @categories = @store.categories.active
    @order = current_order
    if @category
      @products = @category.wesell_items.online.page params[:page]
    elsif @store
      @products = @store.other_wesell_items.online.page params[:page]
    end

    respond_to do |format|
      format.html { render "westore/stores/mall", layout: "wemall" }
      format.js
    end
  end
end