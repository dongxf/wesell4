class Community::SubTagsController < Community::BaseController
	def show
		@sub_tag = SubTag.find params[:id]
		@tag = @sub_tag.tag
		@village = Village.find params[:village_id]
    # @village_items = Kaminari.paginate_array(VillageItem.permit.find_with_sub_tag(@sub_tag.name, @village).list_sort).page(params[:page]).per(9)
    ### undefined method `list_sort' for []:Array
    @village_items = Kaminari.paginate_array(VillageItem.permit.find_with_sub_tag(@sub_tag.name, @village).sort_by(&:weight).reverse).page(params[:page]).per(9)
	end

	def update
		sub_tag = SubTag.find params[:id]
		sub_tag.increment!(:click_count)
		render nothing: true
	end
end
