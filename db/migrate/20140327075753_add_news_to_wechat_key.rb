class AddNewsToWechatKey < ActiveRecord::Migration
  def change
  	add_column :wechat_keys, :title, :string
  	add_column :wechat_keys, :banner, :string
  	add_column :wechat_keys, :url, :string
  	add_column :wechat_keys, :msg_type, :string
  end
end
