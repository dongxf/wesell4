$ ->
  $.fn.editable.defaults.ajaxOptions = {type: "Patch"};
  $('.editable').editable
    validate: (value) ->
      if($.trim(value) == '')
        return '不能为空'

  $('#license_inplace').editable
    ajaxOptions: {type: 'get'}