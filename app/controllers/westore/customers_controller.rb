class Westore::CustomersController < Westore::BaseController
  def intro
    @cst = Customer.find_by id: params[:id]
    intro = params[:intro_update][:intro]
    @cst.update_attributes(intro: intro)
    @wi = WesellItem.find_by id: params[:wesell_item_id]
    CustomerEvent.create(customer_id: @cst.id, target_id: @wi.id, target_type: 'WesellItemId', duration:Time.now, frequency:'real_time', event_type:'checkin_wesell_item',event_count:1,name:'customer_checkin_wesell_item',url:'',comment:'')
    checked_customer_ids=CustomerEvent.where(target_type: 'WesellItemId', target_id: @wi.id, event_type: 'checkin_wesell_item').pluck(:customer_id).uniq
    @checked_customers = Customer.where(id: checked_customer_ids)
    ccount = checked_customer_ids.count
    @wi.update_attributes(checkin_count: ccount) if ccount!=@wi.checkin_count
    respond_to do |format| 
      format.js { render file: 'westore/wesell_items/checkin.js.haml' }
    end
    #@buyers = @wi.buyers
    #@buyers.each do |customer|
    #  if customer.present?
    #    unless customer.id == @cst.id
    #      @title = "#{@cst.nickname}已在#{@wi.name}活动现场签到"
    #      @summary = "开始时间：2015年3月5日下午19:00pm\n活动地点：祈福新村A区7街77号"
    #      @note = '点击详情浏览更多活动信息'
    #      @url = "#{westore_wesell_item_path(@wi)}?instance_id=38"
    #      customer.send_form @summary, @title, @note, @url
    #    end
    #  end
    #end
  end
  def add_info
    @cst = Customer.find_by id: params[:id]
    info = params[:info_update][:info]
    @cst.update_attributes(info: info)
    @wi = WesellItem.find_by id: params[:wesell_item_id]
    od = @wi.the_order_by @cst
    od.description += @cst.info
    od.save
    #respond_to do |format| 
      #format.js { render file: 'westore/wesell_items/add_info.js.haml' }
    #end
    redirect_to "/westore/wesell_items/#{@wi.id}"
  end
end
