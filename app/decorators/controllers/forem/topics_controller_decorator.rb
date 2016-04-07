Forem::TopicsController.class_eval do
	layout "forum"

	private
	def topic_params
	  params.require(:topic).permit!
	end
end
