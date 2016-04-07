# == Schema Information
#
# Table name: wechat_menus
#
#  id                     :integer          not null, primary key
#  instance_id            :integer
#  menu_type              :integer
#  name                   :string(255)
#  key                    :string(255)
#  url                    :string(255)
#  wechat_sub_menus_count :integer          default(0)
#

require 'faraday'
require 'wechat_app'

class WechatMenu < ActiveRecord::Base
  validates_presence_of :instance_id, :name
  validates_presence_of :key, if: -> { menu_type == 'click' }
  validates_presence_of :url, if: -> { menu_type == 'view' }
  validates :name, length: { maximum: 4 }

  belongs_to :instance
  has_many :wechat_sub_menus, -> {order 'sequence asc'}, dependent: :destroy
  accepts_nested_attributes_for :wechat_sub_menus, allow_destroy: true

  MENU_TYPES = {
    click: '事件触发',
    view:  '链接跳转'
  }

  KEYS = {
    kategories:         '店铺分类列表',
    stores:             '店铺列表',
    store:              '店铺详情(适用于单店公众号)', #单店
    instance:           '公众号详情',
    wesell_items:       '商品列表', #需要提供某个店铺的ID,该ID在网址中提供
    orders:             '订单列表',
    membership:         '会员中心',
    # recommended_stores: '返回推荐店铺列表',
    hurry_up:           '催单',
    help:               '帮助信息',
    cs:                 '联系客服',  #customer service
    community:          '社区服务',
    manager:            '管理黄页'
  }

  OLD_KEYS = {
    ORDER_HISTORY: '历史订单',
    ORDER_ARRIVAL: '确认送达',
    ORDER_HURRYUP: '催促送达',
    ORDER_MENU:    '订单状态',
    CUST_NEWS_1:   '关于我们',
    CUST_NEWS_2:   '使用帮助',
    HELP_DESK:     '在线客服',
    WEMBER_MENU:   '会员专享',
    MAIN_NEARBUY:  '服务范围',
    MAIN_POPULAR:  '最受欢迎',
    MAIN_SALES:    '今日特价',
    MAIN_RECENT:   '最常购买',
    MAIN_MENU:     '全部商品',
    BIND_WKEY:     '绑定手机'
  }


  def human_type
    MENU_TYPES[self.menu_type.to_sym] if self.menu_type
  end

  def human_key
    return '' unless key.present?
    tips = KEYS[key.to_sym]
    if tips.blank?
      wechat_key = instance.wechat_keys.where(key: key).first
      tips = wechat_key.present? ? wechat_key.tips : ''
    end
    tips
  end
end
