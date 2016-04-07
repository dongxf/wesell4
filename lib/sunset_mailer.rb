past_days=(Time.now-60.days)..Time.now
iids=Order.where(updated_at: past_days).pluck(:instance_id).uniq;
emails=Instance.where(id: iids).pluck(:email);
emails+=Instance.where(updated_at: past_days).pluck(:email);
emails+=User.where(updated_at: past_days).pluck(:email);
emails+=Store.where(updated_at: past_days).pluck(:email);
phones=Instance.where(id: iids).pluck(:phone);
phones+=Instance.where(updated_at: past_days).pluck(:phone);
phones+=User.where(updated_at: past_days).pluck(:phone);
phones+=Store.where(updated_at: past_days).pluck(:phone);
emails=emails.uniq
phones=phones.uniq
notice="亲爱的赋为点餐及社区O2O平台用户，

春节归来，想必正是燃起冷灶，开门迎顾客的时间，祝亲们生意兴隆！在过去一年多的时间里，在所有收费服务合同都已正常到期履行完毕的情况下，我们的平台继续默默地、无偿和免费地，支持着网络餐饮和社区业务，也得到许多用户的中肯意见和大力支持，在此一并谢过了。

由于业务转型，我们的平台在过去几天可能出现了一些无法使用的情况，鉴于继续维护的费用亏损，我们做出一个决定-平台将被转移到赋为合作伙伴公司的点餐服务上，不愿意转移的用户，我们将在约一个月后关闭访问。

选项A:如果您愿意被迁移到由另一个公司提供的点餐平台，您可以回复本邮件,说明电话号码，联系人或公司名，以及是否继续成为免费用户或付费用户。或者直接等待我们的合作伙伴公司联系您。

选项B：如果您不回应或选择被关闭访问，我们将把您的资料移交给平台关闭工作人员（可能会酌情联系您确认关闭事宜），但不保证后续通知。本邮件视为最终正式关闭通知

如果您有需要备份的客户电话等资料，请您尽快在15个工作日内下载；或者我们也可酌情收人工成本费为您导出。

访问关闭后您将不能以任何方式使用本平台或里面数据

再次感谢您以往对我们的支持！

联系人：董先生
联系邮件：
2124194245@qq.com";
header="赋为点餐及社区O2O平台关闭预告通知";

emails.each do |email|
    ActionMailer::Base.mail(from: "2124194245@qq.com", to: email, subject: header, body: notice).deliver
end

Printer.all.each do |printer|
    printer.print notice;
end
