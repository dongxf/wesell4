require 'wechat_app'

class Comment < ActiveRecord::Base
	belongs_to :customer
	belongs_to :commentable, polymorphic: true, :counter_cache => true

	validates :commentable_id, :customer_id, presence: true
	validates_presence_of :content, message: '评论不能为空'

	has_ancestry
	after_create :send_notice_by_fwdesk
	default_scope -> { order("created_at DESC") }

	def self.arrange_as_array(options={}, hash=nil)
	  hash ||= arrange(options)

	  arr = []
	  hash.each do |node, children|
	    arr << node
	    arr += arrange_as_array(options, children) unless children.empty?
	  end
	  arr
	end

#### 如果是根评论, fwdesk 发送给管理者,
#### 如果非根评论,  comment.parent.customer.instance 发送给 comment.parent.customer
#### 但是略凌乱,  comment.village_item.instance  != comment.customer.instance
#### community base controller 下的session又要跟着乱起来的赶脚,
#### 即便现在看似正常运作, 却暗藏漏洞, session 机制 以及一众 current_x 亟需纠正
	def send_notice_by_fwdesk
		if commentable_type == 'VillageItem' && root?  #comment is root?
		  fwdesk = Instance.find_by name: 'fwdesk'
		  fwdesk_app = WechatApp.new fwdesk

		  text = {
		  	first: "您好!",
		  	fb_form: "#{customer.nickname}在您的黄页发表了评论",
		  	fb_note: "#{content}",
		  	area: "赋为社区©幸福大院",
		  	remark: "发现身边之美，共构社区精彩"
		  }

		  self.commentable.binderers.each do |binderer|
			  text[:url] = "#{ENV['WESELL_SERVER']}/community/village_items/#{commentable_id}/comments/new?parent_id=#{id}&instance_id=#{commentable.instance.id}&customer_cid=#{binderer.cid}"
		    fwdesk_app.send_template fwdesk.template_id, binderer.openid, text
		  end
		elsif commentable_type == 'VillageItem'
			parent_customer = self.parent.customer

			instance = parent_customer.instance
			wechat_app = WechatApp.new instance

			text = {
				url: "#{ENV['WESELL_SERVER']}/community/village_items/#{commentable_id}/comments/new?parent_id=#{id}&instance_id=#{commentable.instance.id}&customer_cid=#{parent_customer.cid}",
				first: "您好!",
				fb_form: "#{customer.nickname}回复了您的评论",
				fb_note: "#{content}",
				area: "赋为社区©幸福大院",
				remark: "发现身边之美，共构社区精彩"
			}

		  wechat_app.send_template instance.template_id, parent_customer.openid, text
		end
	end
end
