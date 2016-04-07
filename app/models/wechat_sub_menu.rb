# == Schema Information
#
# Table name: wechat_sub_menus
#
#  id             :integer          not null, primary key
#  wechat_menu_id :integer
#  menu_type      :integer
#  name           :string(255)
#  key            :string(255)
#  url            :string(255)
#

class WechatSubMenu < ActiveRecord::Base
  validates_presence_of :name, :menu_type
  validates_presence_of :key, if: -> { menu_type == 'click' }
  validates_presence_of :url, if: -> { menu_type == 'view' }
  validates :name, length: { maximum: 7 }

  belongs_to :wechat_menu, counter_cache: true

  def human_type
    WechatMenu::MENU_TYPES[self.menu_type.to_sym] if self.menu_type
  end

  def human_key
    WechatMenu::KEYS[self.key.to_sym] if self.key
  end

end
