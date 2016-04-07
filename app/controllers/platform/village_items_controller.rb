class Platform::VillageItemsController < Platform::BaseController

  load_and_authorize_resource :village
  load_and_authorize_resource through: :village

  def index
    if current_user.role_identifier == :vusr
      @vitems = current_user.owner_village_items
      render 'vusr_index'
    else
      @instance = Instance.find params[:instance_id]
      @village_items = @instance.village_items
      @no_home_village_items = VillageItem.where(instance_id: params[:instance_id]).select { |vi| vi.sub_tags.count == 0 }
      @tags = Tag.all
    end
  end

  def vusr_index
    @vitems = current_user.owner_village_items
    @vstores = current_user.owner_stores
    @tags = Tag.all
  end

  def new
    @instance = Instance.find params[:instance_id]
    @village_item = @instance.village_items.new
    @tags = Tag.all
    @sub_tags = SubTag.all
  end

  def update_user_and_store vitem
    return {status: -1, info:'skip update user&store !vusr', user:nil, store:nil} if current_user.is_vusr?
    #return {status: -1, info: 'user & store NOT updated: not approved level', user: nil, store: nil} if !( vitem.level ==3 || vitem.level == 4 || vitem.level ==5 )
    return {status: -2, info: 'user & store NOT updated: no admin_email', user: nil, store: nil} if vitem.admin_email.blank?
    pwd = '234578'
    name = vitem.admin_name
    vusr_name ||= '未登记商家管理员名称'
    vusr = User.find_by_email vitem.admin_email
    vusr.update_attributes(role_identifier: :vusr, phone: vitem.admin_phone) if vusr
    vusr ||= User.new name: vusr_name, email: vitem.admin_email, password: pwd, password_confirmation: pwd, phone: vitem.admin_phone, role_identifier: :vusr
    vusr.save
    return { status: -3, info: "vusr updated ERROR: #{vusr.errors.messages.to_s}" } if vusr.id.nil?
    vos = Ownership.find_or_create_by user_id: vusr.id, target_id: vitem.id, target_type: 'VillageItem', role_identifier: 'owner'
    vstore = Store.find_by id: vitem.store_id
    if vstore.blank?
      vstore = Store.new instance_id: vitem.instance_id, name: vitem.name, description: vitem.info, phone: vitem.tel, email: vitem.admin_email, street: vitem.addr
      vstore.save
      return { status: -7, info: "vstore NOT updated: #{vstore.errors.messages.to_s}" } if vstore.blank? || vstore.id.nil?
      vitem.update_attributes(store_id:  vstore.id) if vitem.store_id.present?
    end
    vitem.instance.stores << vstore if !vitem.instance.stores.include?(vstore)
    sos = Ownership.find_or_create_by user_id: vusr.id, target_id: vstore.id, target_type: 'Store', role_identifier: 'owner'
    return {status: 0, info: "user & store updated successfully - user.email: #{vusr.email}", user: vusr, store: vstore}
  end

  def send_notice_to_vitem_owner vitem
    return {info: 'skipped send notice when is_vusr'} if current_user.is_vusr?
    return {info: 'skipped notice cause lack of owner cid'} if vitem.owner_id.blank?
    vowner = Customer.find_by id: vitem.owner_id
    return {info: 'NOT send notice cause owner cid not existed!'} if vowner.blank?
    pc_info = vitem.owner_user.present? ? "网址:fooways.com\n用户名:#{vitem.owner_user.email}\n初始密码234578\n" : ''
    mb_info = "手机端绑定密码#{vitem.pin}\n点"
    info = pc_info + mb_info + "击详情了解如何在手机上实时管理黄页信息"
    vowner.send_form "已为您成功在#{@instance.nick}更新商业服务信息","社区商家后台入口地址",info,"http://mp.weixin.qq.com/s?__biz=MzA5NDE2NjAzNw==&mid=203508037&idx=1&sn=c45720ee01f68add8cbc6082c87a9ec3#rd"
    return {info: 'send notice to vitem owner okey'}
  end

  def send_notice_to_vitem_referral vitem
    return {info: 'skipped send thank you notice when is_vusr'} if current_user.is_vusr?
    return {info: 'skepped send thank you notice cause lack of referral cid'} if vitem.referral_id.blank?
    vferral = Customer.find_by id: vitem.referral_id
    return {info: 'NOT send notice cause owner cid not existed!'} if vferral.blank?
    vferral.send_form "您向#{vitem.instance.nick}推荐的黄页信息已收录","感谢您的推荐和分享！","请点击详情查看相关信息","http://fooways.com/community/village_items/#{vitem.id}"
    return {info: 'send thank you note to vitem referall okey'}
  end

  def create
	  @instance = Instance.find params[:instance_id]
  	@village_item = @instance.village_items.build params[:village_item]
    @village_item.villages << @instance.default_village if @village_item.villages.empty? && @instance.default_village.present?
  	if @village_item.save
      ret1 = update_user_and_store @village_item
      ret2 = send_notice_to_vitem_referral @village_item
      ret3 = send_notice_to_vitem_owner @village_item
      flash[:notice] = "#{ret1[:info]} | #{ret2[:info]} | #{ret3[:info]}"
      redirect_to edit_platform_instance_village_item_path(@instance, @village_item)
    else
      render :new
  	end
  end

  def edit
    @instance = Instance.find params[:instance_id]
    @village_item = VillageItem.find params[:id]
    @tags = Tag.all
    @sub_tags = SubTag.all
  end

  def update
    @instance = Instance.find params[:instance_id]
    @village_item = VillageItem.find params[:id]
    if @village_item.update_attributes(params[:village_item])
      ret1 = update_user_and_store @village_item
      ret3 = send_notice_to_vitem_owner @village_item
      flash[:notice] = "#{ret1[:info]} | #{ret3[:info]}"
      redirect_to edit_platform_instance_village_item_path(@instance, @village_item)
    else
      render :edit
    end
  end

  def destroy
    @village_item = VillageItem.find params[:id]
    @instance = @village_item.instance
    @village_item.destroy
    flash[:alert] = "删除成功"
    redirect_to platform_instance_village_items_path(@instance)
  end

  def approved
    @tags = Tag.all
    @instance = Instance.find params[:instance_id]
    @village_items = @instance.village_items.where(level: [2, 3, 4, 5])
  end

  def print_qrcode
    @village_item = VillageItem.find params[:id]
    @village_item.gen_sceneid if !@village_item.sceneid.present?
    sceneid = @village_item.sceneid
    instance = @village_item.instance
    wechat_app = WechatApp.new instance
    @url = wechat_app.get_qrcode_url(sceneid)
    render layout: false
  end

  def join
    if params[:joined] == 'checked'
      Leagueship.find_by(village_item_id: params[:id], village_id: params[:village_id]).destroy
    else
      Leagueship.create village_item_id: params[:id], village_id: params[:village_id]
    end
    render nothing: true
  end

  def import
    VillageItem.import(params[:file], params[:instance_id])
    redirect_to platform_instance_village_items_url, notice: "批量导入成功"
  end

  def logging_data
    request.format = 'csv' if params[:export]

    @instance = Instance.find params[:instance_id]

    query_string = query_filter

    if @instance.name == "foowcn"
      if query_string.present?
        @user_vis = UserVillageItem.where(query_string).group(:user_id).count
      else
        @user_vis = UserVillageItem.group(:user_id).count
      end
    end

    respond_to do |format|
      format.html
      format.csv
    end
  end

	private

	def village_item_params
		params.require(:village_item).permit!
	end

  def query_filter
    query_string = ''
    if params[:created_at_1].present?
      created_at_1 = params[:created_at_1]

      query_string += ' and ' unless query_string.blank?
      query_string += " created_at >= '#{created_at_1}'"
    end

    if params[:created_at_2].present?
      created_at_2 = params[:created_at_2]

      query_string += ' and ' unless query_string.blank?
      query_string += " created_at <= '#{created_at_2}'"
    end

    query_string
  end
end
