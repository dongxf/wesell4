class PicturesController < ApplicationController
	def create
	  @pic = Picture.new(pic: params[:file])

	  respond_to do |format|
	    if @pic.save
	      format.html {
	        render  :json => @pic.to_jq_upload,
					        :content_type => 'text/html',
					        :layout => false
					    # render nothing: true
	      }
	    end
	  end
	end
end
