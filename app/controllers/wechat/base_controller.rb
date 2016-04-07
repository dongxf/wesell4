class Wechat::BaseController < ApplicationController
  layout 'wechat'

  skip_before_filter :verify_authenticity_token
  before_filter :check_wechat_legality
  helper_method :current_instance

private

  def check_wechat_legality
    # if params[:instance_name].nil? || params[:timestamp].nil? || params[:nonce].nil?
    #   render text: 'Invalid params to call service instance', status: 404
    #   return
    # end
    @instance = Instance.find_by name: params[:instance_name]
    if @instance.nil?
      render :text => "Service Instance #{params[:instance_name]} not existed", :status => 404
      return
    end

    # array = [@instance.token, params[:timestamp], params[:nonce]].sort
    # render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
  end

  def current_instance
    @instance
  end
end