cart_num = (mark) ->
  num = parseInt($('.quantity').val())
  if mark == 'plus'
    num += 1
    $('.quantity').val(num)
  else if mark == 'minus' && num > 1
    num -= 1
    $('.quantity').val(num)

$('.wrapper-icon').on _movestartEvt, '.minus', () ->
  cart_num('minus')
$('.wrapper-icon').on _movestartEvt, '.add', () ->
  cart_num('plus')