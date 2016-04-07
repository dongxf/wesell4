class ReportMailer < ActionMailer::Base
	default from: "report@fooways.com"

	def daily report_day, instance
  	@report_day = report_day
    @time_range = @report_day.midnight..@report_day.end_of_day
  	@instance = instance
  	@revenue = 0
  	instance.stores.each do |store|
  		report = Report.find_by_report_date_and_store_id(report_day, store.id)
  		@revenue += report.total_income if report
    end

    # 更新动态 forum
    forum = Forem::Forum.find_by(name: "更新动态")
    @updated = forum.posts.where(created_at: report_day.midnight..(report_day.midnight + 1.day))

    subject = "#{instance.nick}-每日营收汇总-#{report_day}"
    if @revenue > 100
      mail subject: subject, to: instance.email, bcc: 'wesell@fooways.com', from: 'no-reply@fooways.com'
    else
      mail subject: subject, to: instance.email, from: 'no-reply@fooways.com'
    end
	end

  def dash info
    @info = info
    mail subject: "Foowcn Daily #{Time.now.year}-#{Time.now.month}-#{Time.now.day}", to: 'franklin@fooways.com', bcc: 'yolanda@fooways.com', from: 'no-reply@fooways.com'
  end

end
