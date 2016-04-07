$ ->
  $(".category_switch").bootstrapSwitch
    onText: "全上架"
    offText: "全下架"
  .on 'switchChange', (e, data) ->
    category_id = $(e.target).data('category-id')
    store_id = $(e.target).data('store-id')
    $.get "/platform/stores/#{store_id}/categories/#{category_id}/active", (data) ->
      console.log data
