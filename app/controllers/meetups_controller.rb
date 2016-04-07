class MeetupsController < ApplicationController
  respond_to :json

  def index
    respond_with Meetup.all
  end

  def create
    respond_with Meetup.create(comment_params)
  end

  private

  def comment_params
    params.require(:comment).permit(:name, :comment)
  end
end
