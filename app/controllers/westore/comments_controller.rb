class Westore::CommentsController < Westore::BaseController
  before_action :comment_params

  def create
    @comment = current_customer.comments.build params[:comment]
    @vi = WesellItem.find params[:wesell_item_id]
    @comment.commentable = @vi

    current_comments = current_customer.comments.where(commentable_id: params[:wesell_item_id])
    unless current_comments.empty?
      parent = current_comments.last
      @comment.parent = parent
    end

    if @comment.save
      respond_to do |format|
        format.js
      end
    else
      logger.info("=======#{@comment.errors.empty?}======")

      @err = @comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit!
  end
end