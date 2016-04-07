class OrderMailer < ActionMailer::Base
  default from: "wesell@fooways.com"

  def new_order order
    @order = order
    to_mail = order.store.email
    if order.instance.should_email?
      mail  subject: order.subject, to: to_mail, cc: order.instance.email
    else
      mail  subject: order.subject, to: to_mail
    end
  end

  def hurry_up order
    @order = order
    to_mail = order.store.email
    if order.instance.should_email?
      mail  subject: '！！！速度！！！'+ order.subject, to: to_mail, cc: order.instance.email
    else
      mail  subject: '！！！速度！！！'+ order.subject, to: to_mail
    end
  end
end
