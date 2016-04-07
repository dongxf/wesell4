require 'locatable'

class Platform::StoresController < Platform::BaseController
  include Locatable

  def index
    if current_user.admin?
      @stores = Store.undeleted.page(params[:page])
    else
      @stores = current_user.stores.undeleted.page(params[:page])
    end
  end


  def show
    @store = Store.find params[:id]
    @order_configs = @store.order_configs
  end

  def operations
    @store = Store.find params[:id]
    @operations = @store.operations.includes(:instance).page params[:page]
    # @instances = @store.instances.page params[:page]
  end

  def new
    @store = Store.new(time_setting: :nodate, address_setting: :address)
    @store.instance_id = params[:instance_id] if params[:instance_id]
  end

  def create
    instance_id = store_params.delete :instance_id
    @instance = current_user.instances.find(instance_id) if instance_id.present?
    @store = Store.new store_params
    @store.creator = current_user
    if @store.save
      @store.add_manager current_user
      if @instance
        @store.add_operation @instance
        redirect_to platform_instance_store_path(@instance, @store)
      else
        @store.add_operation current_user.instances.all
        redirect_to platform_store_path(@store)
      end
    else
      render :new
    end
  end

  def update
    @store = Store.find params[:id]
    if @store.update_attributes store_params
      redirect_to platform_store_path(@store)
    else
      render :edit
    end
  end

  def invite
    @store = Store.find params[:id]
    @instance = Instance.find_by params[:instance]
    @store.add_operation @instance if @instance
  end

  def invite_code
    @store = Store.find params[:id]
    @store.gen_invite_code
  end

  def add_express
    @store = Store.find params[:id]
    @express = Express.find_by params[:express]
    @store.expresses << @express if @express
  end

  def remove_express
    @store = Store.find params[:id]
    @express = Express.find params[:express_id]
    @store.expresses.delete @express if @express
  end

  def nearby
    @instance = Instance.find params[:instance_id]
    @stores = []
    Store.all.each do |store|
      dist = distance store, @instance
      @stores << store if dist < 10000
    end
  end

  def change_kategory
    @store = Store.find params[:id]
    @instance = Instance.find params[:instance_id]
    @kategory = Kategory.find params[:kategory_id] if params[:kategory_id].present?
    if @kategory
      @store.set_kategory @kategory
    elsif @instance
      @store.set_kategory @kategory, @instance
    end
    render json: {status: 'ok'}, layout: false
  end

  def switch
    store = Store.find params[:id]
    store.toggle!(:open)
    message = store.open? ? "#{store.name} 开始营业" : "#{store.name} 已经关闭"
    render text: message, layout: false
  end

  def copy
    store = Store.find params[:id]
    Store.delay.copy! params[:id], params[:store]
    flash[:notice] = '正在复制。。。稍候请查看店铺列表。。。'
    redirect_to platform_store_path(store)
  end

  def destroy
    begin
      @store = Store.find params[:id]
      @store.destroy
    rescue ActiveRecord::DeleteRestrictionError
      @store.disappear
    end
    flash[:notice] = '店铺已关闭'
    redirect_to action: :index
  end

private

  def store_params
    params.require(:store).permit!
  end
end
