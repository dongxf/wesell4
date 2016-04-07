require 'wechat_app'
namespace :update_customers do
	desc 'update customers info'
	task :update_customers, [:instance_ids] => :environment do |task, args|
    instance_ids = args[:instance_ids].split(" ").map(&:to_i)
		instances = Instance.where(id: instance_ids)
		instances.each do |instance|
      wechat_app = WechatApp.new instance
      instance.customers.find_each do |customer|
        wechat_app.get_user_info customer
        p "done customer #{customer.nickname}"
      end
      p "done instance #{instance.id}"
      p "now is #{Time.now}"
    end
	end
end
