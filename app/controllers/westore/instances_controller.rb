class Westore::InstancesController < Westore::BaseController
  before_filter :check_location, only: [:show]
  #todo, for customers from computer
  def index
    @instances = []
    @instances << current_customer.instance
  end

  def show
    @customer = current_customer
    @kategories = @instance.valid_kategories
    @stores = @instance.localized_stores(@instance.stores, @customer)
  end

  def search
    @instance = Instance.find params[:id]
    set_current_instance @instance

    @search = Operation.solr_search do
      fulltext params[:search][:q], highlight: true
      with :instance_id, current_instance.id
      with :open, true
      order_by :sequence, :asc
      # paginate(:page => params[:page] || 1)
    end
    ids = @search.results.map(&:store_id)
    # for mysql only
    @stores = Store.find ids, :order => "field(id, #{ids.join(',')})"
  end

  def location_tips
  end

private
  def check_location
    @instance = Instance.find_by id: params[:id]
    render "errors/westore_404" and return if @instance.blank?
    set_current_instance @instance
    return true unless @instance.check_location
    return true if current_customer && current_customer.located? #try to use static instance url in wehcat_menu
    @no_bottom = true
    render :location_tips and return
  end
end
