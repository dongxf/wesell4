class Westore::KategoriesController < Westore::BaseController
  def show
    @kategory = Kategory.find params[:id]
    @instance = Instance.find params[:instance_id]
    @stores = @kategory.stores
    if @stores.size == 1
      redirect_to westore_instance_store_path(@instance, @stores.first)
    end
  end
end