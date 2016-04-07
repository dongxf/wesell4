$ ->
  $(".store_switch").bootstrapSwitch
    onText: "营业"
    offText: "打烊"
  .on 'switchChange', (e, data) ->
    store_id = $(e.target).data('store-id')
    $.get "/platform/stores/#{store_id}/switch", (data) ->
      console.log data
