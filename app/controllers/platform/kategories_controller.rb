class Platform::KategoriesController < Platform::BaseController
  before_filter :get_instance

  load_and_authorize_resource :instance
  load_and_authorize_resource through: :instance

  def index
    @kategories = @instance.kategories.page params[:page]
  end

  def new
    @kategory = @instance.kategories.build
  end

  def create
    @kategory = end_of_association_chain.new(kategory_params)
    create! do |success, failure|
      success.js { flash[:notice] = '创建成功'}
      success.html { redirect_to platform_instance_kategories_path(@kategory.instance) }
      failure.html {
        logger.info resource.errors.full_messages
        render :new
      }
    end
  end

  def update
    @kategory = Kategory.find params[:id]
    @kategory.update_attributes kategory_params
    update! do |success, failure|
      success.html { redirect_to platform_instance_kategories_path(@kategory.instance) }
      failure.html {
        render :edit
      }
    end
  end

  def destroy
    @kategory = Kategory.find params[:id]
    @instance = @kategory.instance
    begin
      destroy! {
        flash[:notice] = '删除成功'
        platform_instance_kategories_path(@instance)
      }
    rescue ActiveRecord::DeleteRestrictionError
      flash[:alert] = '类目不为空，无法删除'
      redirect_to platform_instance_kategories_path(@instance)
    end
  end
private

  def kategory_params
    params.required(:kategory).permit!
  end

  def get_instance
    @instance = Instance.find params[:instance_id]
  end
end
