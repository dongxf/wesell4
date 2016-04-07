module Westore::OrdersHelper
  def switch_status order, status, options = {}
    case status
    when :reject
      if order.status == 'rejected'
        link_to '已拒绝', 'javascript:void(0)', class: 'btn btn-default'
      else
        link_to '拒绝', update_order_westore_order_path(order, event: 'reject'), method: 'PATCH', \
        data: {confirm: '确定要拒绝此订单？'}.merge(options), class: 'btn btn-danger'
      end
    when :accept
      if order.status == 'accepted'
        link_to '已接受', 'javascript:void(0)', class: 'btn btn-default'
      else
        link_to '接受', update_order_westore_order_path(order, event: 'accept'), method: 'PATCH', \
        data: options, class: 'btn btn-info'
      end
    when :ship
      if order.status == 'shipped'
        link_to '已发货', 'javascript:void(0)', class: 'btn btn-default'
      else
        link_to '发货', update_order_westore_order_path(order, event: 'ship'), method: 'PATCH', \
        data: options, class: 'btn btn-success'
      end
    when :finish
      if order.status == 'finished'
        link_to '已完成', 'javascript:void(0)', class: 'btn btn-default'
      else
        link_to '完成订单', update_order_westore_order_path(order, event: 'finish'), method: 'PATCH', \
        data: options, class: 'btn btn-salmon'
      end
    end
  end
end