$ ->
  $('.order_order_options').on 'change', 'select', () ->
    option_id = $(this).val()
    $.get "/westore/order_config_options/#{option_id}/price", (data) ->
      total = parseFloat(data.total).toFixed(2)
      $('#total').html(total)
