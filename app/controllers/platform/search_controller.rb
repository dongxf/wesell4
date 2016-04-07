class Platform::SearchController < Platform::BaseController
  # before_filter :admin_required
  skip_load_and_authorize_resource

  def launch
    model = params[:model]
    send("#{model.downcase}_search")
  end

protected

  def user_search
    redirect_to :root and return unless admin_required
    @search = User.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      paginate(:page => params[:page] || 1)
    end
    @users = @search.results
    render 'platform/users/index'
  end

  def instance_search
    @search = Instance.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      paginate(:page => params[:page] || 1)
    end
    @instances = @search.results
    render 'platform/instances/index'
  end

  def operation_search
    @search = Operation.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      paginate(:page => params[:page] || 1)
    end
    @operations = @search.results
    render 'platform/operations/index'
  end

  def store_search
    @search = Store.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      with(:id).any_of(current_user.store_ids) unless current_user.admin?
      paginate(:page => params[:page] || 1)
    end
    @stores = @search.results
    render 'platform/stores/index'
  end

  def village_item_search
    @search = VillageItem.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      with(:instance_id).any_of(current_user.instance_ids) unless current_user.admin?
      paginate(:page => params[:page] || 1)
    end
    @village_items = @search.results 
    # remove unauthorized village items
    @village_items = @search.results & current_user.owner_village_items if current_user.is_vusr?
    @q = params[:q]
    render 'platform/village_items/results'
  end

  def wesell_item_search
    @search = WesellItem.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      with(:store_id).any_of(current_user.store_ids) unless current_user.admin?
      order_by :total_sold, :desc
      paginate(:page => params[:page] || 1)
    end
    @q2 =  params[:q]
    @wesell_items = @search.results
    render 'platform/wesell_items/search'
  end

  def order_search
    @search = Order.solr_search do
      qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
      fulltext qstr, highlight: true
      without :status, 'open'
      paginate(:page => params[:page] || 1)
    end
    @orders = @search.results
    render 'platform/orders/index'
  end

  def admin_required
    unless current_user && current_user.admin?
      flash[:alert] = "只有管理员可以搜索"
      return false
    end
    true
  end
end
