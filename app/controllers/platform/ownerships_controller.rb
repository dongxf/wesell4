class Platform::OwnershipsController < Platform::BaseController
  def create
    @store = Store.find params[:ownership][:target_id]
    create! {render :create and return}
  end

  def destroy
    @store = Store.find resource.target
    destroy! {render :destroy and return}
  end

private
  def ownership_params
    params.require(:ownership).permit!
  end
end
