class Platform::ExpressesController < Platform::BaseController

  def index
    @expresses = current_user.expresses.page(params[:page])
  end

  def new
    @express = Express.new
  end

  def create
    @express = Express.new express_params
    @express.creator = current_user
    if @express.save
      flash[:notice] = "新建成功"
      redirect_to platform_express_path(@express)
    else
      render :new
    end
  end

  private

  def express_params
    params.require(:express).permit!
  end
end
