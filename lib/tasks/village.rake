#encoding utf-8
require 'wechat_app'
require 'instance_report'

namespace :community do

  desc "fooyard rake"
  task :fooyard => :environment do
    ysd = Time.now.yesterday
    drt_all = Date.new(2013,4,1).beginning_of_day..ysd.end_of_day
    drt_week = ysd.end_of_day.ago(6.days).beginning_of_day..ysd.end_of_day
    drt_month = Date.new(2014,3,1).beginning_of_day..ysd.end_of_day
    drt_ysd = ysd.beginning_of_day..ysd.end_of_day


    ii = Instance.find 38
    ir = InstanceReport.new  ii, drt_ysd

    info  = "#{ii.nick} 访问数据汇总\n"
    info += "统计周期: #{drt_ysd}\n"
    info += "\n===============================================\n关注情况汇总\n===============================================\n"
    info += ir.scan_report
    info += "\n===============================================\n流失情况汇总\n===============================================\n"
    info += ir.unsub_report
    #info += "\n===============================================\n在线交易汇总\n===============================================\n"
    #info += ir.stores_report
    info += "\n===============================================\n黄页访问汇总\n===============================================\n"
    info += ir.community_report
    info += "\n===============================================\n访问数据详情\n===============================================\n"
    info += ir.customer_events_report
    info += "\n===============================================\n增值商户汇总\n===============================================\n"
    info += ir.village_items_report

    fname="fooyard-#{Date.today.to_s}.txt"
    fn=File.open("/var/www/wp/#{fname}",'w')
    fn.puts info
    fn.close

    dxf = Customer.find 158597
    fwdesk = Instance.find_by name: 'fwdesk'
    fwdesk_app = WechatApp.new fwdesk

    text = {
      first: "#{Date.today.to_s}访问数据汇总",
      area: "#{ii.nick}",
      url: "http://wp.fooways.com/#{fname}",
      remark: "发现身边之美，共构社区精彩"
    }
    ii.village_items.each do |vi|
      vi.binderers.each do |binderer|
        text[:fb_form] = "#{vi.name}"
        text[:fb_note] = "#{vi.name}\n累计点击：#{vi.click_count}\n累计收藏 #{vi.favor_count}\n...\n点击查看详情"
        fwdesk_app.send_template fwdesk.template_id, binderer.openid, text# if binderer == dxf
      end
    end
  end

end
