class VillageItemMailer < ActionMailer::Base
  default from: "wesell@fooways.com"

  def new_vi village_item
    @village_item = OpenStruct.new village_item
    instance = Instance.find @village_item.instance_id
    @customer = Customer.find @village_item.customer_id
    to_mail = instance.email
    mail  subject: "#{@customer.id}#{@customer.try(:nickname)}-推荐靠谱信息给-#{instance.nick}-#{@village_item.name}", to: to_mail, cc: "franklin@fooways.com"
  end
end
