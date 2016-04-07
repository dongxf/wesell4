# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".order_switch").bootstrapSwitch
    onText: "测试"
    offText: "非测试"
  .on 'switchChange', (e, data) ->
    order_id = $(e.target).data('order-id')
    $.get "/platform/orders/#{order_id}/switch", (data) ->
      console.log data
