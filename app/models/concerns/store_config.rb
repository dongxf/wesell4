module StoreConfig
  extend ActiveSupport::Concern

  TEMPLATES = {
    wemall: '商城版',
    westore: '微店版',
  }

  SETTING_KEYS = [:show_total_sold, :show_phone, :template, :order_offline]
  BOOLEAN_KEYS = [:show_total_sold, :show_phone, :order_offline]

  included do
    has_settings do |s|
      s.key :config, :defaults => {
        show_total_sold: false,
        show_phone: false,
        template: 'westore',
        order_offline: false
      }
    end

    SETTING_KEYS.each do |getter|
      define_method getter do
        self.settings(:config).send(getter)
      end
    end
    SETTING_KEYS.each do |setter|
      define_method "#{setter.to_s}=" do |arg|
        self.settings(:config).send("#{setter}=", arg)
      end
    end

    BOOLEAN_KEYS.each do |key|
      define_method "#{key}?" do
        value = self.settings(:config).send(key)
        (value == true || value == '1') ? true : false
      end
    end
  end

  PAYMENT_OPTIONS = %w[cash balance alipay wechat card]
  HUMAN_PAYMENT_OPTIONS = {
    "wechat"  => '微信支付',
    "alipay"  => '支付宝支付',
    # "balance" => '余额支付',
    "cash"    => '现金支付',
    "card"    => '刷卡支付'
  }

  # attr_accessor :show_total_sold

  # def show_total_sold
  #   defined?(@show_total_sold) ? @show_total_sold : self.settings(:config).show_total_sold
  # end

  # def show_total_sold= value
  #   bool = (value == '1' ? true : false)
  #   @show_total_sold = bool
  #   self.settings(:config).show_total_sold = bool
  # end

  # def show_phone
  #   defined?(@show_phone) ? @show_phone : self.settings(:config).show_phone
  # end

  # def show_phone= value
  #   bool = (value == '1' ? true : false)
  #   @show_phone = bool
  #   self.settings(:config).show_phone = bool
  # end

  # def template
  #   defined?(@template) ? @template : self.settings(:config).template
  # end

  # def template= value
  #   self.settings(:config).template = value
  #   @template = value
  # end

  def payment_options
    PAYMENT_OPTIONS.reject { |r| ((payment_options_mask || 0) & 2**PAYMENT_OPTIONS.index(r)).zero? }
  end

  def payment_options=(options)
    self.payment_options_mask = (options & PAYMENT_OPTIONS).map { |r| 2**PAYMENT_OPTIONS.index(r) }.sum
  end

  def human_payment_options
    # HUMAN_PAYMENT_OPTIONS.slice *payment_options
    HUMAN_PAYMENT_OPTIONS.select { |k, v| payment_options.include? k}
  end
end
