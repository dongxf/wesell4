class Community::VillageItemsController < Community::BaseController
  before_action :find_vi, except: [:recommend, :last_week, :join]

	def show
    @comments = @village_item.comments.includes(:customer).arrange_as_array(order: 'created_at DESC')
    @comments =  Kaminari.paginate_array(@comments).page(params[:page]).per(10)
    if params[:notifier] != 'true'
      @village_item.increment!(:click_count) 
      @village_item.notify_binders(:show_event,current_customer)
      params[:notifier] = 'false'
    end

    if params[:village_id].present?
      @village = Village.find params[:village_id]
    else
      @village = @village_item.villages.first
    end

    @offer = @village_item.offers.last
    respond_to do |format|
      format.html
      format.js
    end
	end

	def favor
    @village_item.favor_by current_customer
    @village_item.reload
    respond_to do |format|
      format.js
	  end
	end

  def edit
    @instance = @village_item.instance
  end

	def update
    params.require(:village_item).permit(:page, :url)
    @village_item.update_attributes(page: params[:village_item][:page], url: params[:village_item][:url])
    redirect_to page_community_village_item_path(@village_item)
	end

  def count
    @village_item.increment!(:call_count)
    @village_item.notify_binders(:call_event,current_customer)
    render nothing: true
  end

  def call_record
    @village_item.increment!(:call_count)
    @village_item.notify_binders(:call_event,current_customer)
    render nothing: true
  end

  def view_record
    @village_item.increment!(:call_count)
    @village_item.notify_binders(:view_event,current_customer)
    render nothing: true
  end

  def go_shop
    @village_item.increment!(:call_count)
    @village_item.notify_binders(:shop_event,current_customer)
  end

  def shop_record
    @village_item.increment!(:call_count)
    @village_item.notify_binders(:shop_event,current_customer)
    render nothing: true
  end

  def page
  end

	def recommend
	  params.require(:vi).permit!
    @instance = Instance.find params[:vi][:instance_id]
	  # @village_item = VillageItem.new(params[:vi])
	  VillageItemMailer.new_vi(params[:vi]).deliver
	end

  def manager
    @village_item = VillageItem.find(params[:id])
    @offer = @village_item.offers.last
  end

  def qrcode
    unless @village_item.sceneid.present?
      @village_item.gen_sceneid
    end
    @sceneid = @village_item.sceneid
    @instance = @village_item.instance
    @wechat_app = WechatApp.new @instance
    @url = @wechat_app.get_qrcode_url(@sceneid)
  end

  def last_week
    #不带customer_cid, 只能靠session
    @instance = Instance.find params[:instance_id] if params[:instance_id].present?
    @tags = Tag.all
    @sub_tags = SubTag.all
    @village = @instance.villages.first
    #todo: village_items 不一定有相同的 first village
    @village_items = @instance.village_items.where(created_at: (Date.today-7).end_of_day..Date.today.end_of_day).page(params[:page]).per(9)
    @title = "过去一周新增商户"
    render 'community/villages/show'
  end

  def join
    if params[:joined] == 'checked'
      Leagueship.find_by(village_item_id: params[:id], village_id: params[:village_id]).destroy
    else
      Leagueship.create village_item_id: params[:id], village_id: params[:village_id]
    end
    render nothing: true
  end

  private

  def find_vi
    @village_item = VillageItem.find params[:id]
  end
end
