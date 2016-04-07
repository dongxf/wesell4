class Community::CommentsController < Community::BaseController
  before_action :comment_params, only: :create

  def new
    @parent = Comment.find params[:parent_id]
    @village_item = VillageItem.find params[:village_item_id]
    @comment = @village_item.comments.new(parent_id: params[:parent_id], customer_id: current_customer.id)
  end

  def create
    if params[:customer_id].present?  #reply from template
      @comemnt = Comment.new params[:comment]
    else
      @comment = current_customer.comments.build params[:comment]
    end

    @vi = VillageItem.find params[:village_item_id]
    @comment.commentable = @vi

    if @comment.save
    	respond_to do |format|
    		format.js
        format.html { redirect_to community_village_item_path(@vi) }
    	end
    else
	    @err = @comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit!
  end
end
