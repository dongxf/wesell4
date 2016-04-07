module Wechat::BindProcessor
  def process_binding content
    key, code = content.split(' ')
    render nothing: true and return unless key.present? && code.present?

    case key
    when '绑定店铺'
      @bindable = Store.find_by invite_code: code
      if @bindable.present?
        @bindable.bind_customer @customer
        render 'wechat/services/binds/bind_store' and return
      end
    when '松绑店铺'
      @bindable = Store.find_by invite_code: code
      if @bindable.present?
        @bindable.unbind_customer @customer
        render 'wechat/services/binds/unbind_store' and return
      end
    when '绑定公众号'
      @bindable = Instance.find_by invite_code: code
      if @bindable.present?
        @bindable.bind_customer @customer
        render 'wechat/services/binds/bind_instance' and return
      end
    when '松绑公众号'
      @bindable = Instance.find_by invite_code: code
      if @bindable.present?
        @bindable.unbind_customer @customer
        render 'wechat/services/binds/unbind_instance' and return
      end
    when '绑定黄页'
      @bindable = VillageItem.find_by pin: code
      bind_count = @customer.binders.count
      if @bindable.present?
        if bind_count == 9
          @over_max = true
          render 'wechat/services/binds/bind_village_item' and return
        else
          @bindable.bind_customer @customer
          render 'wechat/services/binds/bind_village_item' and return
        end
      end
    when '松绑黄页'
      @bindable = VillageItem.find_by pin: code
      if @bindable.present?
        @bindable.unbind_customer @customer
        render 'wechat/services/binds/unbind_village_item' and return
      end
    when '绑定配送'
      @bindable = Express.find_by invite_code: code
      if @bindable.present?
        @bindable.bind_customer @customer
        render 'wechat/services/binds/bind_express' and return
      end
    when '松绑配送'
      @bindable = Express.find_by invite_code: code
      if @bindable.present?
        @bindable.unbind_customer @customer
        render 'wechat/services/binds/unbind_express' and return
      end
    end
    if @bindable.blank?
      render 'wechat/services/binds/not_found'
    end
  end
end
