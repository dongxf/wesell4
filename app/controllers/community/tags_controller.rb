class Community::TagsController < Community::BaseController
	def show
		@tag = Tag.find params[:id]
		@village = Village.find params[:village_id]
    # @village_items = Kaminari.paginate_array(VillageItem.permit.find_with_tag(@tag.name, @village).list_sort).page(params[:page]).per(9)
    ### undefined method `list_sort' for []:Array
    @village_items = Kaminari.paginate_array(VillageItem.permit.find_with_tag(@tag.name, @village).sort_by(&:weight).reverse).page(params[:page]).per(9)
	end

	def update
		tag = Tag.find params[:id]
		tag.increment!(:click_count)
		render nothing: true
	end
end
