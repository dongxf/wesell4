class Misc::PearlsController < Misc::BaseController
  before_filter :no_header

  def create
    @pearl = Pearl.new pearl_params
    create! do |success, failure|
      success.html { redirect_to misc_pearl_path(resource) }
      failure.html { render :new }
    end
  end

private
  def pearl_params
    params.require(:pearl).permit!
  end
end
