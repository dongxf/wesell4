class OrderAction < ActiveRecord::Base
  belongs_to :order
  belongs_to :actioner, polymorphic: true

  TYPES = {
    canceled:        '已撤销',
    rejected:        '卖家已拒绝此订单',   # 店家拒绝此单
    require_payment: '等待买家付款',      # 买家选择先付款时，使用此状态
    paid:            '买家已付款',
    accepted:        '卖家接受此单',      # 店家正在处理订单时，将订单设为此状态
    reposted:        '卖家已转发配送',
    shipped:         '卖家已发货',        # 店家发货后，将订单设为此状态，如外卖
    received:        '买家已收货',        # 买家收货后，店家将订单设为received
    confirmed:       '订单完成',
    hurry_up:        '催单'
  }
  symbolize :action_type, in: TYPES.keys, scopes: :shallow, methods: true

  # default_scope { order('order_actions.created_at DESC') }

  def self.log order, action, actioner=nil
    if actioner
      actioner_type = actioner.class.name
      actioner_id = actioner.id
      order.order_actions.create action_type: action, actioner_type: actioner_type, actioner_id: actioner_id
    else
      order.order_actions.create(action_type: action)
    end
  end

  def human_type
    TYPES[action_type]
  end
end
