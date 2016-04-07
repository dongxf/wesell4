class ChangeDataFormatInWechatMenu < ActiveRecord::Migration
  def up
    change_column :wechat_menus, :url, :text
  end

  def down
    change_column :wechat_menus, :url, :string
  end
end
