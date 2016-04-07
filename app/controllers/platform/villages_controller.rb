require 'wechat_app'

class Platform::VillagesController < Platform::BaseController
  def new
    @village = Village.new
    @instance = Instance.find params[:instance_id]
  end

  def create
    # instance_id = village_params.delete :instance_id
    @instance = Instance.find params[:instance_id]
    @village = @instance.villages.new village_params
    # if instance_id.present?
    #   @instance = current_user.instances.find instance_id
    #   @village.instance = @instance
    # end
    if @village.save
      flash[:notice] = "新建成功"
      if @instance.name == "foowcn"
        fwdesk = Instance.find_by name: "fwdesk"
        wechat_app = WechatApp.new fwdesk
        binders = Binder.where(target_id: @instance.village_item_ids, target_type: "VillageItem")

        binders.each do |binder|
          text = {
            url: manager_community_village_item_url(binder.target, customer_cid: binder.customer.cid, instance_id: fwdesk.id),
            first: "您好!",
            fb_form: "#{@village.name} 已在幸福大院落地",
            fb_note: "请选择是否在相关区域开通#{binder.target.name}的服务。点击进入服务开通设置",
            area: "赋为社区©幸福大院",
            remark: "发现身边之美，共构社区精彩"
          }

          wechat_app.send_template fwdesk.template_id, binder.customer.openid, text
        end
      end
      redirect_to [:platform, @instance, @village]
    else
      render :new
    end
  end

  def index
    @instance = current_instance
    @villages = @instance.villages
  end

  def show
    @tags = Tag.all
    @instance = Instance.find params[:instance_id]
    @no_home_village_items = VillageItem.where(village_id: params[:id]).select { |vi| vi.sub_tags.count == 0 }
  end

  def edit
    @village = Village.find params[:id]
    @instance = Instance.find params[:instance_id]
  end

  def update
    @village = Village.find params[:id]
    @instance = @village.instance
    if @village.update_attributes(params[:village])
      flash[:notice] = "更改成功"
      redirect_to edit_platform_instance_village_path(@instance, @village)
    else
      render :edit
    end
  end

  def destroy
    @instance = Instance.find params[:instance_id]
    @village = Village.find params[:id]
    @village.destroy

    redirect_to platform_instance_villages_path(@instance)
  end

  def comments
    @village = Village.find params[:id]
    @instance = @village.instance
    @comments = @village.comments.page(params[:page])
  end

  def records
    @village = Village.find params[:id]
    @instance = @village.instance
    @records = @instance.records.page(params[:page])
  end

  private

  def village_params
	  params.require(:village).permit!
  end
end
