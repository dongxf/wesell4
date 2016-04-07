class Platform::PrintersController < Platform::BaseController
  # before_filter :get_store

  load_and_authorize_resource :store
  load_and_authorize_resource through: :store

  def index
    @printers = @store.printers
  end

  def create
    @printer = end_of_association_chain.new(printer_params)
    create! do |success, failure|
      success.html { redirect_to platform_store_printers_path }
      failure.html {
        logger.info resource.errors.full_messages
        render :new
      }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to platform_store_printers_path }
      failure.html {
        logger.info resource.errors.full_messages
        render :edit
      }
    end
  end

  def destroy
    destroy! { platform_store_printers_path(resource.store) }
  end

private

  def printer_params
    params.require(:printer).permit!
  end

  def begin_of_association_chain
    @store = Store.find params[:store_id]
  end
end
