#encoding utf-8

namespace :foowcn do


  desc "add foowable stores to foowcn, or remove unfoowable stores from foowcn"

  task :add_foowable_stores => :environment do
    foowcn = Instance.find_by_name 'foowcn'
    Store.all.each do |store|
      foowcn.stores << store if !foowcn.stores.include?(store) && store.foowable?
    end
  end

  task :remove_unfoowable_stores => :environment do
    foowcn = Instance.find_by_name 'foowcn'
    foowcn.operations.each do |opr|
      opr.destroy if !opr.store.foowable?
    end
  end

  #
  def pcounts drt
    ucount = User.where(created_at: drt).count
    icount = Instance.where(created_at: drt).count
    scount = Store.where(created_at: drt).count
    ccount = Customer.where(created_at: drt).count

    bcount = Order.where(created_at: drt).count
    ocount = Order.where(submit_at: drt).count
    amount = Order.where(submit_at: drt).sum(:amount).round

    info = "\n-------------------------------\nnew created #{drt}\n"
    info += "users|instances|stores|customers|browsing|order|amount\n"
    info += "#{ucount}|#{icount}|#{scount}|#{ccount}|#{bcount}|#{ocount}|#{amount}\n"
    return info
  end

  #列出新注册用户
  def pusrs drt
    usrs=User.where(created_at: drt)
    info = "\n-------------------------------\nnew usrs info #{drt}\n"
    usrs.each do |usr|
      nicks = ''
      phones = ''
      usr.instances.each do |is|
        nicks += is.nick
        phones += is.phone
      end
      info += "#{usr.id}|#{usr.name}|#{usr.email}|#{nicks}|#{phones}\n"
    end
    return info
  end

  def pactive drt, cond

    ods = Order.where(created_at: drt) if cond=='created_at'
    ods ||= Order.where(submit_at: drt)

    info = "\n-------------------------------\nactived #{drt} #{cond}\n"

    ulist=Hash.new
    ilist=Hash.new
    slist=Hash.new
    clist=Hash.new

    ods.each do |od|
         ulist[od.instance.creator.id] = 0 if od.instance && od.instance.creator && ulist[od.instance.creator.id].nil?
         ilist[od.instance.id] = 0 if od.instance && ilist[od.instance.id].nil?
         slist[od.store.id] = 0 if od.store && slist[od.store.id].nil?
         clist[od.customer.id] = 0 if od.customer && clist[od.customer.id].nil?

         ulist[od.instance.creator.id] +=1 if od.instance && od.instance.creator
         ilist[od.instance.id] += 1 if od.instance
         clist[od.customer.id] += 1 if od.customer
         slist[od.store.id] += 1 if od.store
    end

    ulist=Hash[ulist.sort_by{|k,v| v}.reverse]
    ilist=Hash[ilist.sort_by{|k,v| v}.reverse]
    slist=Hash[slist.sort_by{|k,v| v}.reverse]
    clist=Hash[clist.sort_by{|k,v| v}.reverse]

    info += "users|instances|stores|customers\n"
    info += "#{ulist.count}|#{ilist.count}|#{slist.count}|#{clist.count}\n"

    info += "top5 ilist\n"
    ilist.take(5).each do |id,count|
      ist = Instance.find(id)
      info += "#{count}|#{id}|#{ist.nick}|#{ist.phone}|#{ist.email}\n"
    end

    return info

  end

  task :dash => :environment do
    ysd = Time.now.yesterday
    drt_all = Date.new(2013,4,1).beginning_of_day..ysd.end_of_day
    drt_week = ysd.end_of_day.ago(6.days).beginning_of_day..ysd.end_of_day
    drt_month = Date.new(2014,3,1).beginning_of_day..ysd.end_of_day
    drt_ysd = ysd.beginning_of_day..ysd.end_of_day

    info = "\n===============================\nfoowcn dash task info\n"
    info += "===============================\n"

    info += pusrs drt_ysd

    info += pcounts drt_all
    info += pcounts drt_week
    info += pcounts drt_ysd

    info += pactive drt_week, 'created_at'
    info += pactive drt_week, 'submit_at'

    info += pactive drt_ysd, 'created_at'
    info += pactive drt_ysd, 'submit_at'

    info += "\n"
    info += "=============================== searched review\n"
    info += searched_review drt_ysd
    info += "=============================== comments review\n"
    info += comments_review drt_ysd
    info += "=============================== hottest searched\n"
    info += hottest_searched
    info += "=============================== subscribed stats\n"

    foo_report = InstanceReport.new(Instance.find(38), drt_ysd)
    info += foo_report.scan_report
    info += foo_report.unsub_report
    info += foo_report.village_items_report

    ReportMailer.dash(info).deliver

    update_vscore
    update_meta
    remove_employee_data

  end

  def update_meta
    str = ''
    VillageItem.all.each do |vi|
      vi.sub_tags.each do |st|
        if vi.meta
          vi.meta += " #{st.name}" unless vi.meta.include? st.name
        end
      end
      vi.tags.each do |tg|
        if vi.meta
          vi.meta += " #{tg.name}" unless vi.meta.include? tg.name
        end
      end
      #str += "#{vi.meta} \n"
      vi.save
    end
    str
  end

  #vscore is updated periodly via crontab
  def update_vscore
    VillageItem.find_each do |vi|
      vi.update commenters_count: vi.comments.group(:customer_id).length
      print "update #{vi.name}..\n"
    end
    vis = VillageItem.all
    vis_count = vis.count
    vis_count += 1
    click_sum = vis.sum(:click_count)
    favor_sum = vis.sum(:favor_count)
    call_sum = vis.sum(:call_count)
    commenter_sum = 0
    vis.each { |v| commenter_sum +=v.commenters_count }
    average_wfc = 100.0*favor_sum / ( click_sum + call_sum + 1)
    average_score = (favor_sum*4+call_sum*2+click_sum*1+commenter_sum*3+1)/(vis.count+1)
    vis.each do |vi|
      #using 14 days as age unit 
      age = (Time.now-vi.created_at)/24/60/60/14
      age = 1 if age < 1
      ldrt = (Time.now-14.days)..Time.now
      show_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "show_event", created_at: ldrt).count
      view_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "view_event", created_at: ldrt).count
      call_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "call_event", created_at: ldrt).count
      favor_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "favor_event", created_at: ldrt).count
      unfavor_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "unfavor_event", created_at: ldrt).count
      shop_event = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", event_type: "shop_event", created_at: ldrt).count
      cs_count = CustomerEvent.where(target_id: vi.id, name: "customer_click_village_item", created_at: ldrt).pluck(:customer_id).uniq.count
      recent_score = show_event + 2*view_event + 2*call_event + 2*shop_event + 3*cs_count + 4*favor_event - 4*unfavor_event + (vi.approved? ? 2 : 1 ) 
      history_score = ( vi.favor_count*4+vi.call_count*2+vi.click_count*1+3*vi.commenters_count + ( vi.approved? ? 2 : 1 ) )
      wfc = ( 100.0*vi.favor_count ) / ( vi.click_count + vi.call_count + 1 )
      weight = wfc/average_wfc
      vscore = recent_score * 0.5 + ( history_score - average_score ) * 0.2 + ( weight * age ) * 0.3

      vi.update_attribute(:vscore, vscore)
      if vi.level == 2 || vi.level == 3 || vi.level == 4 || vi.level == 5
        vi.update_attribute(:level, 1) if vi.approved_end_at && Time.now > vi.approved_end_at
      end
    end
  end

  def approve_public_items
  end

  #100.times { |i| update_vscore; sleep 789 }
  #
  def employee_cids; [18061,18299,22267,58957,60418,132346,201912,188921,18032,18013,194162] end

  def remove_employee_data
    employee_cids.each do |cid|
      searched = Record.where(customer_id: cid)
      searched.destroy_all
    end
    #Record.pluck(:content).uniq
  end

  def is_internal_cid eid; employee_cids.include? eid end

  def searched_review drt
    rcds=Record.where(created_at: drt).order(:result_count)
    rtr="记录号 || 搜索词 || 结果数 || 客户号 || 客户名 || 服务号 || 服务名 || 处理结果 \n"
    rcds.each do |rcd|
      cst = rcd.customer
      ins = rcd.instance
      rtr += "#{rcd.id} || #{rcd.content} || #{rcd.result_count} || #{cst.id} || #{cst.nickname} || #{ins.id} || #{ins.nick} || \n" if !(is_internal_cid cst.id)
    end
    #puts rtr
    return rtr
  end

  def comments_review drt
    cmts=Comment.where(created_at: drt).order(:id).reverse
    str="记录号 || 评论词 || 客户号 || 客户名 || 商店号 || 商店名 || 处理结果 \n"
    cmts.each do |cmt|
      if cmt.commentable_type == 'VillageItem'
        cst = cmt.customer
        vtm = VillageItem.find cmt.commentable_id
        str += "#{cmt.id} || #{cmt.content} || #{cst.id} || #{cst.nickname} || #{vtm.id} || #{vtm.name} || \n" if !(is_internal_cid cst.id)
      end
    end
    #puts str #这个每天运行发送给运营者
    return str
  end

  def hottest_searched
    key_list=Record.pluck(:content).uniq
    hots={}
    key_list.each do |key|
      hots[key] = Record.where(content: key).count
    end
    hots.keys.sort { |a,b| hots[b] <=> hots[a] }
    keys = hots.keys.sort_by{|a| hots[a]}.reverse[1..10]
    ktr="优先级 || 搜索词 || 搜索数 || 处理结果 \n"
    nm=1
    keys.each { |key|  ktr += "#{nm} || #{key} || #{Record.where(content: key).count} || \n"; nm+=1 }
    return ktr
  end


  def hottest_review
    rcds=Record.pluck(:content,:result_count,:customer_id)
    hots={}
    rcds.each do |rcd|
      if !is_internal_cid(rcd[3])
        hots[rcd[0]] = 0 if hots[rcd[0]].nil?
        hots[rcd[0]] += rcd[1]
      end
    end
    hots.keys.sort { |a,b| hots[b] <=> hots[a] }
    keys=hots.keys.sort_by{|a| hots[a]}.reverse[1..10]
    nm=1
    ktr="优先级 || 搜索词 || 搜索数 || 处理结果 \n"
    keys.each { |key|  ktr += "#{nm} || #{key} || #{hots[key]} || \n"; nm+=1 }
    #puts ktr
    return ktr
  end

  def clean_zombie_instances
    drt=Date.new(2013,3,1).beginning_of_day..(Date.today-30.days).end_of_day
    str=''
    Instance.where(created_at: drt).each do |ii|
      if ii.customers.count == 0 && ii.orders.count == 0 && ii.nick == '示例公众号'
        ii.stores.each do |ss|
          if ss.name == '示例商店' && ss.orders.count == 0
            ss.wesell_items.destroy_all
            ss.destroy
          else
            str += "ii #{ii.id} del ss #{ss.id} #{ss.name} #{ss.orders.count} #{ss.wesell_items.pluck(:name).join('')}\n"
          end
        end
        ii.destroy
      else
        str += "ii #{ii.id} more: #{ii.nick} #{ii.customers.count} #{ii.stores.pluck(:name).join(' ')}\n"
      end
    end
    str
  end

  #drt=Time.now.yesterday.beginning_of_day...Time.now.yesterday.end_of_day
  def vl_rep drt
    str = "#{drt}\n\n"
    str += "#{comments_review drt}\n"
    str += "#{searched_review drt} \n"
    str += "#{hottest_searched} \n"
  end

end
