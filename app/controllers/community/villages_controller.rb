class Community::VillagesController < Community::BaseController

  def index
    @villages = current_instance.villages
  end

	def show
    @tags = Tag.all
    @sub_tags = SubTag.all
    @village = Village.find params[:id]
    session[:default_village] = @village.id
    current_customer.update_attributes(default_village_id: @village.id)
    @village_items = Kaminari.paginate_array(@village.village_items.permit.list_sort).page(params[:page]).per(9)
	end

	def search
		@village = Village.find params[:id]  # can not write outside the block
    qstr = params[:q] =~ /^\d+$/ ? params[:q]+'*' : params[:q]
	  @search = VillageItem.solr_search do
		  fulltext qstr, highlight: true
      # with :village_ids, params[:id]
      with :instance_id, Village.find(params[:id]).instance_id
      without :level, 0
      order_by :vscore, :desc
      paginate :page => params[:page], :per_page => 9
	  end
    @village_items = @search.results
    @rmsg = "搜索 #{qstr}"
	  Record.create content: params[:q], instance_id: @village.instance.id, customer_id: current_customer.id, result_count: @search.results.count
	end

  def offers
    @tags = Tag.all
    @sub_tags = SubTag.all
    @village = Village.find params[:id]
    @village_items = Kaminari.paginate_array(@village.village_items.has_offers).page(params[:page]).per(9)
    @rmsg = '最新优惠'
    render :search
  end

  def set_default
    current_customer.update! default_village_id: params[:id]
    render nothing: true
  end
end
