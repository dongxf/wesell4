imgUrl = if $('#logo').length > 0 then $('#logo').prop('src') else $('body').find('img').prop('src')

lineLink = window.location.href + "?instance_id=#{$('body').data('instance-id')}"
descContent = ""
shareTitle = document.title
appid = ''

shareFriend = ->
  WeixinJSBridge.invoke "sendAppMessage",
    "appid": appid
    "img_url": imgUrl
    "img_width": "200"
    "img_height": "200"
    "link": lineLink
    "desc": descContent
    "title": shareTitle
  , (res) ->

  return

shareTimeline = ->
  WeixinJSBridge.invoke 'shareTimeline',
    "img_url": imgUrl
    "img_width": "200"
    "img_height": "200"
    "link": lineLink
    "desc": descContent
    "title": shareTitle
  , (res) ->

  return

document.addEventListener "WeixinJSBridgeReady", (onBridgeReady = ->

  WeixinJSBridge.on "menu:share:appmessage", (argv) ->
    shareFriend()
    return

  WeixinJSBridge.on "menu:share:timeline", (argv) ->
    shareTimeline()
    return

  return
), false
