class Platform::OrderConfigsController < Platform::BaseController
  before_filter :get_store

  def new
    @order_config = @store.order_configs.build
  end

  def create
    create! do |success, failure|
      success.html { redirect_to platform_store_path(@store) }
      failure.html { render :new }
    end
  end

  def edit
    edit!
  end

  def update
    update! do |success, failure|
      success.html { redirect_to platform_store_path(@store) }
      failure.html { render :edit }
    end
  end

  def destroy
    destroy! { platform_store_path(@store) }
  end

private

  def order_config_params
    params.require(:order_config).permit!
  end

  def get_store
    if params[:store_id].present?
      @store = Store.find params[:store_id]
    end
  end
end
