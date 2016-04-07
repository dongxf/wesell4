class CreateWechatMenus < ActiveRecord::Migration
  def change
    create_table :wechat_menus do |t|
      t.integer :instance_id
      t.string :menu_type
      t.string :name
      t.string :key
      t.string :url
      t.integer :wechat_sub_menus_count, null: false, default: 0
      t.integer :sequence, default: 0
    end
  end
end
