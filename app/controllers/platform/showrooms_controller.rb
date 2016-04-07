class Platform::ShowroomsController < Platform::BaseController
  before_action :find_instance
  def index
    @showrooms = @instance.showrooms.page(params[:page])
  end

  def new
    @showroom = Showroom.new
  end

  def create
    @showroom = @instance.showrooms.build params[:showroom]
    if @showroom.save
      flash[:notice] = "新建成功"
      redirect_to edit_platform_instance_showroom_path(@instance, @showroom)
    else
      render :new
    end
  end

  def edit
    @showroom = Showroom.find params[:id]
  end

  def update
    @showroom = @instance.showrooms.build params[:showroom]
    if @showroom.save
      flash[:notice] = "更改成功"
      redirect_to edit_platform_instance_showroom_path(@instance, @showroom)
    else
      render :edit
    end
  end

  def destroy
    @showroom = Showroom.find params[:id]
    @showroom.destroy
    flash[:alert] = "删除成功"
    redirect_to platform_instance_showrooms_path(@instance)
  end

  private

  def showroom_params
    params.require(:showroom).permit!
  end

  def find_instance
    @instance = Instance.find params[:instance_id]
  end
end
