class InstanceReport

  def initialize instance, duration
    @instance = instance
    @duration = duration
  end

  def employee_cids; [18061,18299,22267,58957,60418,132346,201912,188921,18032,18013,194162,303066,204400,110545,158597,273351,335146,110563,204693] end
  #303066 那片云
  #204400 陈东汉
  #110545 酸橙之家
  #158597 董学锋 18061
  #273351 热一度
  #335146 Melody倩
  #110563 xguox
  #204693 珊
  #

  def scene_name sid
    vis = @instance.village_items.where(sceneid: sid)
    return "V#{sid.to_s.ljust(6)},#{vis.first.name}" if vis.first.present?
    ops = @instance.operations.where(sceneid: sid)
    return "S#{sid.to_s.ljust(6)},#{ops.first.store.name}" if ops.first.present?
    return "N#{sid.to_s.ljust(6)},N/A"
  end

  def scan_report
    insid = @instance.id
    drt = @duration
    sids=Customer.where(instance_id: insid, created_at: drt).where('openid is not null').pluck(:from_sceneid)
    uids=Customer.where(instance_id: insid, created_at: drt, subscribed: false).where('openid is not null').pluck(:from_sceneid)
    cids=Customer.where(instance_id: insid, created_at: drt).where('openid is not null').pluck(:id)
    str = "总关注数量 #{sids.count} 总流失: #{uids.count}\n"
    sname={}
    scount={}
    lcount={}
    sqty=0
    idx=0
    sids.each do |sid|
      cst = Customer.find cids[idx]
      idx += 1
      lcount[sid] ||= 0
      lcount[sid] += cst.subscribed ? 0 : 1
      sqty += 1 if sid != 0
      if sname[sid].nil?
        sname[sid] = "#{scene_name(sid)}"
        scount[sid] = 1
      else
        scount[sid] += 1
      end
    end
    str += "经推广二维码关注数量：#{sqty}\n"
    sname.each { |k,v| str += "#{v},+#{scount[k]},-#{lcount[k]}\n" }
    return str
  end

  def unsub_report
    insid = @instance.id
    drt = @duration
    coffs = Customer.where(instance_id: insid, subscribed: false, updated_at: drt).where('openid is not null')
    str = "总流失用户数量 #{coffs.count}\n"
    mints={}
    chns={}
    coffs.each do |coff|
      hrs=((coff.updated_at-coff.created_at)/60/60).to_i
      dys=hrs/24
      wks=dys/7
      mts=dys/30
      st = "数小时内"
      st = "数天之内" if dys > 0
      st = "数周之内" if wks > 0
      st = "数月之内" if mts > 0
      if mints[st].nil?
        mints[st] = 1
      else
        mints[st] += 1
      end
      fsid=coff.from_sceneid
      if chns[fsid].nil?
        chns[fsid] = 1
      else
        chns[fsid] += 1
      end
    end
    mints=mints.sort_by{ |k,v| v}.reverse
    str += "关注时长 流失人数\n"
    mints.each { |k,v| str += "#{k} #{v}\n"}
    chns=chns.sort_by{ |k,v| v}.reverse
    str += "关注渠道 流失人数\n"
    chns.each { |k,v| str += "#{scene_name(k)} #{v}\n"}
    return str
  end

  def community_report
    vis=VillageItem.where(instance_id: @instance.id, level: [2,3])
    vis_ids=VillageItem.where(instance_id: @instance.id, level: [2,3]).pluck(:id)
    str  = "总黄页条目数: #{VillageItem.where(instance_id: @instance.id).count}\n"
    str += "增值商户总数: #{VillageItem.where(instance_id: @instance.id, level: [2,3]).count}\n"
    str += "绑定客户端数: #{Binder.where(target_type: 'VillageItem', target_id: vis_ids).count}\n"
    str += "累计拨打次数: #{@instance.village_items.sum(:click_count)}\n"
    str += "累计收藏次数: #{@instance.village_items.sum(:favor_count)}\n"
    return str
  end

  def customer_events_report
    vis = VillageItem.where(instance_id: @instance.id)
    iivis = VillageItem.where(instance_id: @instance.id).pluck(:id)
    viids=CustomerEvent.where(target_id: iivis, target_type: 'VillageItem').pluck(:target_id).uniq
    last_day = Time.now.yesterday.beginning_of_day..Time.now.yesterday.end_of_day
    csrp = {}
    strp = {}
    viids.each do |viid|
      showc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'show_event').count
      shopc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'shop_wevent').count
      viewc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'view_event').count
      callc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'call_event').count
      favrc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'favor_event').count
      unfvc = CustomerEvent.where(target_id: viid, created_at: last_day, event_type: 'unfavor_event').count
      actvc = showc + shopc + viewc + callc + favrc + unfvc
      if actvc > 0
        csrp[viid]=actvc
        strp[viid]="#{viid},#{actvc},#{showc},#{viewc},#{shopc},#{callc},#{favrc},#{unfvc},#{VillageItem.find(viid).name}"
      end
    end
    wcsp =  csrp.sort_by {|k,v| v}.reverse
    str = "序号,总访问,查看,详情,进店,电话,收藏,取消,名称\n"
    wcsp.each do |k, v|
      str += "#{strp[k]}\n"
    end
    return str
  end

  def village_items_report
    vis=VillageItem.where(instance_id: @instance.id, level: [2,3])
    vis_ids=VillageItem.where(instance_id: @instance.id, level: [2,3]).pluck(:id)
    vstr = "序号,名字,电话,黄页绑定码,绑定数,累计点击数,店铺详情,链接,高级,商铺号,商铺绑定码,绑定数,备注\n"
    str = "序号,名字,累计拨打次数,累计收藏次数,累计在线订单,备注\n"
    huge_cids = []
    vis.each do |vi|
      cst_ids = Binder.where(target_type: 'VillageItem', target_id: vi.id).pluck(:customer_id)
      binded_vi_cidc = (cst_ids - employee_cids).count
      huge_cids += (cst_ids - employee_cids)
      ivc = 'n/a'
      ivc = Store.find(vi.store_id).invite_code if !vi.store_id.nil?
      binded_st_cidc = 0
      cst2_ids = []
      odsc = '--'
      #vtsc= '--'
      if vi.store_id
        cst2_ids = Binder.where(target_type: 'Store', target_id: vi.store_id).pluck(:customer_id)
        binded_st_cidc = (cst2_ids - employee_cids).count
        huge_cids += (cst2_ids - employee_cids)
        od1 = Order.unopen.where(store_id: vi.store_id).count#, created_at: @duration).count
        #od2 = Order.where(store_id: vi.store_id).count#, created_at: @duration).count
        odsc = od1.to_s
        #vtsc = (od2-od1).to_s
      end
      cstids = (cst_ids + cst2_ids).uniq - employee_cids
      #att = '*'*cstids.count
      att = cstids.to_s.gsub(', ','|')
      att = '---------------------' if att == '[]'
      vstr += "#{vi.id},#{vi.name},#{vi.tel},#{vi.pin},#{binded_vi_cidc},#{vi.click_count},#{vi.page.nil? ? 'n/a' : 'yes'},#{vi.url.blank? ? 'n/a' : 'yes'},#{vi.level==3 ? 'n/a' : 'yes'},#{vi.store_id.nil? ? 'n/a' : vi.store_id},#{ivc},#{binded_st_cidc},#{att}\n"
      str += "#{vi.id},#{vi.name},#{vi.click_count},#{vi.favor_count},#{odsc},#{att}\n" if !vi.name.include?('小管家')
    end
    fname="villages-#{Date.today.to_s}.txt"
    fn=File.open("/var/www/wp/#{fname}",'w')
    fn.puts vstr
    fn.close
    return str
  end

  def warray ary
    idxs=ary.uniq
    keys={}
    ary.each { |idx| keys[idx] = keys[idx].present? ? keys[idx]+1 : 1 }
    warray =  keys.sort_by {|k,v| v}.reverse
  end

end
