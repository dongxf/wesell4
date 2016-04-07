require 'locatable'

class Platform::InstancesController < Platform::BaseController
  include Locatable

  def index
    if current_user.admin?
      @instances = Instance.page(params[:page])
    else
      @instances = current_user.instances.page(params[:page])
    end
  end

  def create
    @instance = Instance.new instance_params
    @instance.creator = current_user
    if @instance.save
      @instance.add_manager current_user
      redirect_to platform_instance_path(@instance), notice: '创建成功'
    else
      render :new
    end
  end

  def update
    @instance = Instance.find params[:id]
    if @instance.update_attributes instance_params
      redirect_to platform_instance_path(@instance), notice: '更新成功'
    else
      render :edit
    end
  end

  def invite
    @instance = Instance.find params[:id]
    @store = Store.find_by params[:store]
    @instance.add_operation @store if @store
  end

  def invite_code
    @instance = Instance.find params[:id]
    @instance.gen_invite_code
  end

  def nearby
    @store = Store.find params[:store_id]
    @instances = []
    Instance.all.each do |instance|
      dist = distance instance, @store
      @instances << instance if dist < 10000
    end
  end

  def roles
    @instance = Instance.find(params[:id])
    @ownerships = @instance.ownerships.includes(:user)
  end

  private

  def instance_params
    params.require(:instance).permit!
  end
end
