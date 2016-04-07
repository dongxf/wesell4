class Platform::CategoriesController < Platform::BaseController
  before_filter :get_store

  load_and_authorize_resource :store
  load_and_authorize_resource through: :store

  def index
    @categories = @store.categories.page params[:page]
  end

  def show
    @category = Category.find params[:id]
    @wesell_items = @category.wesell_items.undeleted.page params[:page]
    if params[:status] == "offline"
      @wesell_items = @wesell_items.offline.page params[:page]
    elsif params[:status] == "online"
      @wesell_items = @wesell_items.online.page params[:page]
    end
    render 'platform/wesell_items/index'
  end

  def new
    @category = @store.categories.build
  end

  def create
    @category = end_of_association_chain.new(category_params)
    create! do |success, failure|
      success.html { redirect_to platform_store_categories_path(@category.store) }
      failure.html {
        logger.info resource.errors.full_messages
        render :new
      }
    end
  end

  def update
    @category = Category.find params[:id]
    @category.update_attributes category_params
    update! do |success, failure|
      success.html { redirect_to platform_store_categories_path(@category.store) }
      failure.html {
        render :edit
      }
    end
  end

  def destroy
    @category = Category.find params[:id]
    @store = @category.store
    begin
      destroy! {
        flash[:notice] = '删除成功'
        platform_store_categories_path(@store)
      }
    rescue
      flash[:alert] = '类目不为空，无法删除'
      redirect_to platform_store_categories_path(@store)
    end
  end

  def active
    category = Category.find params[:id]
    category.toggle!(:activated)
    if category.activated
      category.wesell_items.each do |wi|
        wi.update_attributes status: 0
      end
    else
      category.wesell_items.each do |wi|
        wi.update_attributes status: 10
      end
    end
    message = category.activated ? "#{category.name} 所有商品已上架" : "#{category.name} 所有商品已下架"
    render text: message, layout: false
  end

private

  def category_params
    params.required(:category).permit!
  end

  def get_store
    @store = Store.find params[:store_id]
  end
end
