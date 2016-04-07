# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# $ ->
$(".select2").select2
  placeholder: "请选择"
  allowClear: true
.on
  change: (e) ->
    $this = $(this)
    store_id = $this.data('store-id')
    instance_id = $this.data('instance-id')
    $.get "/platform/stores/#{store_id}/change_kategory?instance_id=#{instance_id}&kategory_id=#{e.val}", (data) ->
      if data.status == 'ok'
        console.log 'ok'
        notify $this.parents('td'), '更新成功', 'text-success'
        # $this.parents('td').append('<p class="text-success">更新成功</p>')
      else
        console.log 'not ok'
        notify $this.parents('td'), '更新失败，请重试！', 'text-danger'
        # $this.parents('td').append('<p class="text-danger">更新失败，请重试！</p>')


notify = (ele, message, type) ->
  if $(ele).find(".#{type}").length
    $(ele).find(".#{type}").html message
  else
    $(ele).append("<p class=#{type}>#{message}</p>")

  setTimeout () ->
    $(ele).find(".#{type}").html ''
  , 1000
