class CreateWechatSubMenus < ActiveRecord::Migration
  def change
    create_table :wechat_sub_menus do |t|
      t.integer :wechat_menu_id
      t.string :menu_type
      t.string :name
      t.string :key
      t.string :url
      t.integer :sequence, default: 0
    end
  end
end
