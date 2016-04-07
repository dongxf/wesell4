class Community::InstancesController < Community::BaseController
  def index
    @instances = Instance.all
  end
  def select_instance
    @instances = Instance.all
    render "index"
  end
  def search
    @q = params[:search][:q]
    @search = Village.solr_search do
      fulltext params[:search][:q], highlight: true
    end
    @villages = Kaminari.paginate_array(@search.results).page(params[:page]).per(9)
  end
  def show
    redirect_to community_villages_path and return if current_instance.present?
    render "errors/westore_404"
  end
  def home_village
    instance = current_instance
    customer = current_customer
    render "errors/westore_404" and return if instance.blank? || customer.blank?
    redirect_to community_villages_path and return if customer.default_village_id.blank? && session[:default_village].blank?
    @village = Village.find_by id: customer.default_village_id if customer.default_village_id.present?
    @village ||= Village.find_by(id: session[:default_village]) if session[:default_village]
    if @village.present?
      customer.update_attributes(default_village_id: @village.id)
      session[:default_village] = @village.id
      redirect_to community_village_path(@village) and return 
    end
    render "errors/westore_404"
  end
end
