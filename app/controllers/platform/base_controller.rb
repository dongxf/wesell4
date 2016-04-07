class Platform::BaseController < InheritedResources::Base
  layout 'platform'

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  load_and_authorize_resource

  before_filter :authenticate_user!
  before_filter :set_current

  helper_method :current_instance, :current_store

  rescue_from ActiveRecord::RecordNotFound  do |e|
    logger.info e.message
    logger.info e.backtrace
    not_found
  end

private

  def set_current
    if params[:instance_id]
      @current_instance = Instance.find params[:instance_id]
    elsif params[:store_id].present?
      @current_store = Store.find params[:store_id]
    end
  end

  def current_instance
    @current_instance
  end

  def current_store
    @current_store
  end

  def no_permission
    flash[:notice] = '您没有足够的权限，请联系管理员'
    redirect_to :root
  end

  def not_found
    render "errors/not_found", layout: false
  end
end