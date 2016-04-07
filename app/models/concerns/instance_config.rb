module InstanceConfig
  extend ActiveSupport::Concern

  SUBSCRIBE_REPLY_TEMPLATES = [['店铺分类', 'kategories'],
                               ['店铺列表', 'stores'],
                               ['公众号介绍', 'instance'],
                               ['单店直达', 'store'],
                               ['小区黄页', 'community']]

  MENU_TEMPLATES = [['标准图文模板-标题链接促销商品', 'westore'],
                    ['介绍优先模板-标题链接商店介绍', 'wst_intro'],
                    ['多店铺显示模版-显示主项为商品', 'mws_a'],
                    ['多店铺显示模版-显示主项为商店', 'mws_b' ],
                    ['多店铺分类显示模版-显示主项为商店类目', 'tags']]

  SETTING_KEYS = [:subscribe_reply, :menu_template, :sub_lottery,
                  :lottery_count, :lottery_start_at, :should_email, :handle_missing_keys, :wechat_auth]
  BOOLEAN_KEYS = [:sub_lottery,  :should_email, :handle_missing_keys, :wechat_auth]

  included do
    # attr_accessor
    has_settings do |s|
      s.key :wechat, :defaults => {
        subscribe_reply: 'kategories',  #用户关注后的回复消息
        menu_template: 'westore', #菜单模板
        sub_lottery: false,
        lottery_count: 0,
        lottery_start_at: Date.today,
        should_email: true,
        handle_missing_keys: true,
        wechat_auth: false
      }
    end

    SETTING_KEYS.each do |getter|
      define_method getter do
        self.settings(:wechat).send(getter)
      end
    end
    SETTING_KEYS.each do |setter|
      define_method "#{setter.to_s}=" do |arg|
        self.settings(:wechat).send("#{setter}=", arg)
      end
    end

    BOOLEAN_KEYS.each do |key|
      define_method "#{key}?" do
        value = self.settings(:wechat).send(key)
        (value == true || value == '1') ? true : false
      end
    end
  end
end
