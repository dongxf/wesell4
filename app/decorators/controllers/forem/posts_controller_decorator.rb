Forem::PostsController.class_eval do
	layout "forum"

	private
	def post_params
		# pry
	  params.require(:post).permit!
	end
end
