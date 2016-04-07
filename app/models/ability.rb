class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.admin? || user.bizop?
      can :manage, :all
    else
      can :manage, User, id: user.id
      cannot :index, User unless user.admin?

      # can [:new, :create], [Instance, Store, Category, Kategory, WesellItem, WesellItemOption, WechatMenu]

      # can :manage, [Order, Customer, Printer]

      can :manage, Instance do |instance|
        instance.new_record? ? true : user.instances.include?(instance)
      end
      can :read, Instance do |instance|
        user.operated_instances.include? instance
      end

      can :manage, Customer do |customer|
        user.instances.include?(customer.instance)
      end

      can :manage, WechatMenu do |menu|
        menu.instance.present? ? user.instances.include?(menu.instance) : true
      end
      can :manage, WechatKey do |key|
        key.instance.present? ? user.instances.include?(key.instance) : true
      end

      can :manage, Store do |store|
        store.new_record? ? true : user.stores.include?(store)
      end

      can :manage, Showroom do |showroom|
        showroom.new_record? ? true : user.instances.include?(showroom.instance)
      end

      can :manage, Express do |express|
        express.new_record? ? true : user.expresses.include?(express)
      end

      can [:read, :change_kategory], Store do |store|
        user.operated_stores.include? store
      end

      can :manage, Order do |order|
        user.instance_orders.include?(order) || user.store_orders.include?(order)
      end

      can :manage, OrderConfig do |order_config|
        order_config.store.present? ? user.stores.include?(order_config.store) : true
      end

      can :manage, Category do |category|
        category.new_record? ? true :  user.stores.include?(category.store)
      end

      can :manage, Kategory do |kategory|
        kategory.new_record? ? true :  user.instances.include?(kategory.instance)
      end

      can :manage, WesellItem do |wesell_item|
        wesell_item.new_record? ? true :  user.stores.include?(wesell_item.store)
      end

      can :manage, WesellItemOption do |option|
        option.wesell_item.present? ? user.stores.include?(option.wesell_item.store) : true
      end

      can :manage, OptionsGroup do |options_group|
        options_group.wesell_item.present? ? user.stores.include?(options_group.wesell_item.store) : true
      end

      can :manage, Printer do |printer|
        printer.new_record? ? true : user.printers.include?(printer)
      end

      can :manage, Operation do |operation|
        user.stores.include?(operation.store) || user.instances.include?(operation.instance)
      end

      can :manage, OrderAction do |order_action|
        user.instance_orders.include?(order_action.order) || user.store_orders.include?(order_action.order)
      end

      can :manage, Ownership do |ownership|
        ownership.target.present? ? user.stores.include?(ownership.target) : true
      end

      can :manage, Village do |village|
        village.instance.present? ? user.instances.include?(village.instance) : true
      end

      can :manage, VillageItem do |village_item|
        if village_item.new_record? || user.owner_village_items.include?(village_item)
          true
        else
          village_item.instance.present? ? user.instances.include?(village_item.instance) : true
        end
      end

      can :manage, [Comment, Record, Reply]
    end
  end
end
