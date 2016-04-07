require 'wechat_app'

class Platform::OperationsController < Platform::BaseController
  def index
    if params[:instance_id].present?
      @instance = Instance.find params[:instance_id]
      @operations = @instance.operations.includes(:store).page params[:page]
    else
      if current_user.admin?
        @operations = Operation.page params[:page]
      else
        operations = current_user.instance_operations.includes(:instance, :store)
        # operations += current_user.store_operations.includes(:instance, :store)
        @operations = Kaminari.paginate_array(operations.uniq!).page params[:page]
      end
    end
  end

  def update
    if params[:name] == 'sequence' && params[:value].present?
      resource.update_attributes(sequence: params[:value])
    end
    render json: {message: 'ok'}
  end

  def destroy
    destroy! {redirect_to :back and return}
  end

  def spread_qrcode
    @operation = Operation.find params[:id]
    @store = @operation.store
    @wechat_app = WechatApp.new @operation.instance
    sid = @operation.gen_sceneid
    @url = @wechat_app.get_qrcode_url(sid) if @wechat_app.present?
  end

private

  def operation_params
    params.require(:operation).permit!
  end
end
