class ErrorsController < ApplicationController
  def not_found
  	render :layout => false
  end

  def westore_404
    logger.info "westore_404: #{request.remote_ip} #{params}"
  end
end
