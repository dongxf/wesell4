$ ->
  $(".product_switch").bootstrapSwitch
    onText: "正常"
    offText: "已下架"
  .on 'switchChange', (e, data) ->
    wesell_item_id = $(e.target).data('wesell-item-id')
    $.get "/platform/wesell_items/#{wesell_item_id}/switch", (data) ->
      console.log data
