#encoding: utf-8
namespace :data_report do
  BEGINING = Date.new(2014, 1, 28)
  MIN_WUS = 30

  def dr_report store, report_day
    drs_start = report_day.midnight
    drs_end = report_day.end_of_day

    item_sold = 0

    dr = Report.find_or_create_by(report_date: report_day, store_id: store.id)

    total_orders = store.orders.where(updated_at: drs_start..drs_end)
    valid_orders = store.orders.unopen.where(updated_at: drs_start..drs_end)
    total_income = store.orders.unopen.where(updated_at: drs_start..drs_end).sum(:amount)
    valid_orders.each do |order|
      order.order_items.each { |item| item_sold += item.quantity }
    end

    dr.update_attributes! total_orders: total_orders.count,
                          valid_orders: valid_orders.count,
                          total_income: total_income.round(2),
                          item_sold: item_sold
  end

  desc "This will genereate daily reports"
  task :yesterday_report => :environment do
    report_day = Date.yesterday

    users = User.includes(:instances)

    users.each do |uu|
      uu.instances.includes(:stores).each do |ii|
        ii.stores.each do |store|
          dr_report store, report_day
        end
      end
    end

    # User.all.each do |uu|
    #   uu.instances.each do |ii|
    #     ii.stores.each do |store|
    #       dr_report store, report_day
    #     end
    #   end
    # end

    # Send Email
    Instance.all.each do |ii|
      ReportMailer.delay.daily(report_day, ii) if ii.customers.count >= MIN_WUS
    end

    # User.all.each do |uu|
    #   UserMailer.seller_drs(report_day, uu).deliver if uu.dealership == 'demo'
    # end

    # tr_report report_day, sampling_conditions, sampling_users, sampling_instances, sampling_stores

    # clear all open orders and open customers not updated for many days
    old_days=(Time.now-1000.days)..(Time.now-30.days)
    Order.open.where(created_at: old_days, updated_at: old_days).destroy_all
    Customer.where('openid is null and subscribed is FALSE').where(created_at: old_days,updated_at: old_days).destroy_all

  end

  desc "to generate all ever report"
  task :ever_report => :environment do
    users = User.includes(:instances).includes(:stores)

    (BEGINING..Date.today).to_a.each do |report_day|
      users.each do |uu|
        uu.instances.each do |ii|
          ii.stores.each do |store|
            dr_report store, report_day
          end
        end
      end
    end
  end
end
