$ ->
  $(".customer_switch").bootstrapSwitch
    onText: "正常"
    offText: "拉黑"
  .on 'switchChange', (e, data) ->
    customer_id = $(e.target).data('customer-id')
    $.get "/platform/customers/#{customer_id}/switch", (data) ->
      console.log data
