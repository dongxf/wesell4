class Platform::OrderActionsController < Platform::BaseController
  def destroy
    destroy! { platform_order_path(resource.order) }
  end
end
