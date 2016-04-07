class Platform::OptionsGroupsController < Platform::BaseController
  before_filter :get_wesell_item

  load_and_authorize_resource :wesell_item
  load_and_authorize_resource through: :wesell_item

  def new
    @options_group = @wesell_item.options_groups.build
  end

  def create
    create! do |success, failure|
      success.html { redirect_to platform_store_wesell_item_path(@store, @wesell_item) }
      failure.html { render :new }
    end
  end

  def edit
    edit!
  end

  def update
    update! do |success, failure|
      success.html { redirect_to platform_store_wesell_item_path(@store, @wesell_item) }
      failure.html { render :edit }
    end
  end

  def destroy
    @wesell_item
    destroy! { platform_store_wesell_item_path(@store, @wesell_item) }
  end

private

  def options_group_params
    params.require(:options_group).permit!
  end

  def get_wesell_item
    if params[:wesell_item_id].present?
      @wesell_item = WesellItem.find params[:wesell_item_id]
      @store = @wesell_item.store
    end
  end
end
