class PearlMailer < ActionMailer::Base
  default from: "news@fooways.com"

  def signup pearl
    @pearl = pearl
    to_mail = 'foowcn@fooways.com'

    mail  subject: '杉树计划报名', to: to_mail, cc: 'vicky@fooways.com, banxiaoshi086@163.com, tom@fooways.com, 985604068@qq.com'
  end
end
