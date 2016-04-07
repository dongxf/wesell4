#encoding utf-8
require 'wechat_app'
require 'instance_report'

namespace :community do
  desc "fooyard weekly rake"
  task :fooyard_report => :environment do
    def scene_name sid
      vis = @instance.village_items.where(sceneid: sid)
      return "V#{sid.to_s}-#{vis.first.name}" if vis.first.present?
      ops = @instance.operations.where(sceneid: sid)
      return "S#{sid.to_s}-#{ops.first.store.name}" if ops.first.present?
      return "N#{sid.to_s}-N/A"
    end

    def warray ary
      idxs=ary.uniq
      keys={}
      ary.each { |idx| keys[idx] = keys[idx].present? ? keys[idx]+1 : 1 }
      warray =  keys.sort_by {|k,v| v}.reverse
    end

    def human_warray ary
      tmp = warray ary
      rsl = []
      tmp.each do |em|
        k = em[0]
        v = em[1]
        rsl << "#{scene_name(k)}=>#{v}"
      end
      return rsl
    end

    def warray_top ary; human_warray(ary)[0] end

    @instance = Instance.find 38
    iics = Customer.where(instance_id: @instance.id).pluck(:id)
    wk0=(Time.now-14.days).beginning_of_day..(Time.now-8.days).end_of_day
    wk1=(Time.now-7.days).beginning_of_day..(Time.now-1.days).end_of_day
    weeks = { 'wk0' => wk0, 'wk1' => wk1 }

    str = "#每周绩效统计\n"
    weeks.each { |wkn,wk| str += "#{wkn}: #{wk}\n" }

    str += "\n##黄页访问统计\n"
    str += "周期,浏览,查看,订购,拨打,总计,访客\n"
    weeks.each do |wkn, wk|
      showc = CustomerEvent.where(created_at: wk, event_type: 'show_event').count
      viewc = CustomerEvent.where(created_at: wk, event_type: 'view_event').count
      shopc = CustomerEvent.where(created_at: wk, event_type: 'shop_event').count
      callc = CustomerEvent.where(created_at: wk, event_type: 'call_event').count
      activec = CustomerEvent.where(created_at: wk, target_type: 'VillageItem').count
      visitorc = CustomerEvent.where(created_at: wk, target_type: 'VillageItem').pluck(:customer_id).uniq.count
      str += "#{wkn},#{showc},#{viewc},#{shopc},#{callc},#{activec},#{visitorc}\n"
    end

    str += "\n##商户使用统计\n"
    str += "周期,新增,绑定,增值\n"
    weeks.each do |wkn, wk|
      vids = VillageItem.where(created_at: wk).pluck(:id)
      newc = VillageItem.where(created_at: wk).count
      vasc = VillageItem.where(created_at: wk).where('level = 2 or level = 3').count
      bindc = Binder.where(target_type: 'VillageItem', target_id: vids).count
      str += "#{wkn},#{newc},#{bindc},#{vasc}\n"
    end

    str += "\n##推广关注统计\n"
    str += "周期,净增,新增,流失,扫码次数,首要推广码,首要关注渠道,首要流失渠道\n"
    weeks.each do |wkn,wk|
      jzc=Customer.where(created_at: wk, instance_id: @instance.id, subscribed: true).count
      xzc=Customer.where(created_at: wk, instance_id: @instance.id).where("openid is not null").count
      lsc=Customer.where(created_at: wk,subscribed: false, instance_id: @instance.id).where("openid is not null").count
      sm=CustomerEvent.where(created_at: wk, event_type: 'scan_sceneid', customer_id: iics).pluck(:target_id)
      smc=sm.count
      mg=Customer.where(created_at: wk, instance_id: @instance.id, subscribed: true).pluck(:from_sceneid)
      mgc=mg.count
      ml=Customer.where(created_at: wk, instance_id: @instance.id, subscribed: false).where("openid is not null").pluck(:from_sceneid)
      mlc=ml.count
      str += "#{wkn},#{jzc},#{xzc},#{lsc},#{smc},#{warray_top sm},#{warray_top mg},#{warray_top ml}\n"
    end

    puts str

    fname="wk-#{Date.today.to_s}.txt"
    fn=File.open("/var/www/wp/#{fname}",'w')
    fn.puts info
    fn.close

    #dxf = Customer.find 158597
    #fwdesk = Instance.find_by name: 'fwdesk'
    #fwdesk_app = WechatApp.new fwdesk

    text = {
      first: "#{Date.today.to_s}",
      area: "#{@instance.nick}",
      url: "http://wp.fooways.com/#{fname}",
      remark: "发现身边之美，共构社区精彩"
    }

    #fwdesk_app.send_template fwdesk.template_id, dxf.openid, text

  end
end
