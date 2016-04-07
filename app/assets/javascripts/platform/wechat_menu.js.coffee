$ ->
  if $('.wechat-form').length
    $('.wechat-form').on 'change', 'select.wechat_menu_type', (e) ->
      if $(this).val() == 'click'
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_url').hide()
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_url').find('input').prop('disabled', true)
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_key').show()
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_key').find('select').prop('disabled', false)
      else
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_url').show()
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_url').find('input').prop('disabled', false)
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_key').hide()
        $(this).parents('.form-group').siblings('.form-group.wechat_menu_key').find('select').prop('disabled', true)
