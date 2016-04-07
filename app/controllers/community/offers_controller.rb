class Community::OffersController < Community::BaseController
  before_action :find_village_item, :offer_params
  before_action :offer_params, only: [:create, :update]
  def new
    @offer = @village_item.offers.new
  end

  def create
    @offer = @village_item.offers.build params[:offer]
    if @offer.save
      flash[:alert] = '新建成功'
      redirect_to manager_community_village_item_path(@village_item)
    else
      redirect_to new_community_village_item_offer_path(@village_item)
    end
  end

  def edit
    @offer = Offer.find params[:id]
  end

  def update
    @offer = Offer.find params[:id]
    if @offer.update_attributes params[:offer]
      flash[:alert] = '更改成功'
      redirect_to manager_community_village_item_path(@village_item)
    else
      redirect_to edit_community_village_item_offer_path(@village_item, @offer)
    end
  end

  def show
    @offer = Offer.find params[:id]
  end

  private

  def find_village_item
    @village_item = VillageItem.find params[:village_item_id]
  end

  def offer_params
    params.require(:offer).permit!
  end
end
