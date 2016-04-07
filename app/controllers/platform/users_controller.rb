class Platform::UsersController < Platform::BaseController
  before_filter :admin_required, only: [:index, :license, :login]
  def index
    @users = User.page params[:page]
  end

  def show
    if current_user.admin?
      @user = User.find params[:id]
    else
      @user = current_user
    end
    @instances = @user.instances
  end

  def license
    @user = User.find params[:id]
    @license = License.find params[:value]
    @user.add_license @license
    render json: {status: 'ok'}
  end

  def login
    @user = User.find params[:id]
    sign_in :user, @user
    redirect_to :root
  end

  def new_manager
    email = params[:manager][:email]
    name = params[:manager][:name]
    phone = params[:manager][:phone]

    unless User.exists?(email: email)
      fwdesk = Instance.find_by name: "fwdesk"
      @instance = Instance.find_by name: "foowcn"

      @user = User.create email: email, name: email, password: "4000432013", password_confirmation: "4000432013", keeper_id: User.where("keeper_id IS NOT NULL").count+7
      @store = Store.new name: "幸福小管家-#{name}", phone: phone, street: '祈福新村幸福大院运营工作室', creator_id: current_user.id, email: email, description: "幸福小管家", open: true
      @store.save(validate: false)

      @store.instances << [@instance, fwdesk]
      @store.managers << [@user, current_user]

      @village_item = VillageItem.new name: "幸福小管家-#{name}", tel: phone, addr: '祈福新村幸福大院运营工作室', instance_id: @instance.id
      @village_item.save(validate: false)
      @village_item.sub_tag_list = ["其他"]
      @village_item.village_list = "1"
    end
  end

  def print
    @keeper = User.find params[:user_id]

    @village_item = VillageItem.find params[:village_item_id]
    unless @village_item.sceneid.present?
      @village_item.gen_sceneid
    end

    sceneid = @village_item.sceneid
    instance = @village_item.instance
    wechat_app = WechatApp.new instance
    @url_vi = wechat_app.get_qrcode_url(sceneid)

    @store = Store.find params[:store_id]
    operation = Operation.find_by store_id: params[:store_id], instance_id: instance.id
    @url_store = wechat_app.get_qrcode_url(operation)
    render layout: false
  end
end
