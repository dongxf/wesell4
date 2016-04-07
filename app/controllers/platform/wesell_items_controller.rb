require 'wechat_app'
class Platform::WesellItemsController < Platform::BaseController
  before_filter :get_store

  load_and_authorize_resource :store
  load_and_authorize_resource through: :store

  def index
    @wesell_items = @store.wesell_items.includes(:category).undeleted.page params[:page]
    if params[:status] == "offline"
      @wesell_items = @wesell_items.offline.page params[:page]
    elsif params[:status] == "online"
      @wesell_items = @wesell_items.online.page params[:page]
    end
  end


  def new
    @wesell_item = WesellItem.new
    @wesell_item.category_id = params[:category_id] if params[:category_id]
    @wesell_item.store_id = params[:store_id]
  end

  def create
    create! do |success, failure|
      success.html { redirect_to platform_store_wesell_items_path }
      failure.html {
        logger.info resource.errors.full_messages
        render :new
      }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to platform_store_wesell_items_path }
      failure.html {
        logger.info resource.errors.full_messages
        render :edit
      }
    end
  end

  def show
    @wesell_item = WesellItem.find params[:id]
    @options_groups = @wesell_item.options_groups
  end

  def switch
    @wesell_item = WesellItem.find params[:id]
    if @wesell_item
      if @wesell_item.offline?
        @wesell_item.online
      else
        @wesell_item.offline
      end
      render json: {message: 'ok'}
    end
  end

  def sequence
    @wesell_item = WesellItem.find params[:id]
    @wesell_item.update_attribute :sequence, params[:value]
    render json: {message: 'ok'}
  end

  def destroy
    begin
      destroy! {
        flash[:notice] = '商品删除成功'
        platform_store_wesell_items_path(resource.store)
      }
    rescue ActiveRecord::DeleteRestrictionError
      logger.info "+++++++++#{resource.inspect}+++++"
      resource.delete!
      redirect_to platform_store_wesell_items_path(resource.store), notice: '商品删除成功'
    end
  end

  def copy
    wesell_item = WesellItem.find params[:id]
    @wesell_item = wesell_item.copy! params[:wesell_item]
    if @wesell_item.new_record?
      render :new
    else
      redirect_to platform_store_wesell_item_path(wesell_item.store, @wesell_item)
    end
  end

  def reply
    @wesell_item = WesellItem.find params[:id]
    @wesell_item.update remark: params[:reply][:remark2]
    @orders = @wesell_item.orders.where("submit_at IS NOT NULL")
    @instance = @orders.first.instance
    url = params[:reply][:url]

    wechat_app = WechatApp.new @instance
    @orders.each do |o|
      ###how about same customers?
      customer = o.customer
      params[:reply][:url] = url +"?instance_id=#{@instance.id}&customer_cid=#{customer.cid}&comment=true"
      wechat_app.send_template @instance.template_id, customer.openid, params[:reply]
    end
  end
private

  def wesell_item_params
    params.required(:wesell_item).permit!
  end

  def get_store
    @store = Store.find params[:store_id] if params[:store_id]
  end
end
