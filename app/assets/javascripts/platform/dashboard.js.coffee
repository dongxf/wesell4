$('.tab-pane li a').on 'click', () ->
  $(this).parent().siblings().removeClass('active')
  $(this).parent().addClass('active')
