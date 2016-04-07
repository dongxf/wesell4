# encoding: utf-8
class Api::ApplicationController < ActionController::Base
  layout false
  skip_before_filter :verify_authenticity_token
  before_filter :check_client_legality

  private
  # 根据参数校验请求是否合法，如果非法返回错误页面
  def check_client_legality
    if params[:email].nil? || params[:api_token].nil?
      render text: 'Invalid params, please check api document', status: 404
      return
    end
    @user = User.find_by_email(params[:email])
    render text: "Forbidden, please check api document", :status => 403 if @user.nil?
    return if @user.nil?
    render text: "Forbidden, please check api document", :status => 403 if params[:api_token] != @store.invite_code
  end

end

