$ ->
  # showPicInfo()
  # if $('#navBar').length
  #   height = $(window).height()
  #   $('#navBar').height(height)
  #   $('#infoSection').height(height)

  setHeight = ->
    cHeight = undefined
    cHeight = document.documentElement.clientHeight
    cHeight = cHeight + "px"
    document.getElementById("navBar").style.height = cHeight
    document.getElementById("infoSection").style.height = cHeight
    return

  #ajax处理
  #配合_doAjax方法使用
  doSelect = ->
    dds = _qAll("#navBar dd")
    aa = 0
    bb = undefined
    article = _q("#infoSection article")
    _forEach dds, (ele, idx, dds) ->
      dds[idx].onclick = ->
        _q(".active").className = null
        @className = "active"
        div = document.getElementById("pInfo")
        div.innerHTML = ""
        categoryId = this.getAttribute('categoryId')
        $.get "/westore/categories/"+categoryId, (ret) ->
          # unless ret["code"] is 0
          #   alert ret["message"]
          #   return

          if _q(".active").getAttribute("categoryId") is categoryId
            div.innerHTML = ret
            _q("#infoSection").scrollTop = 0
            doSelectBtn()
            #showPicInfo()
          return

        return

      return

    return

  #选择菜品按钮样式
  doSelectBtn = ->
    # countDish();
    #是否需要删除提醒

    # console.log(_self);

    # 变化打数字

    # 字体放大显示
    # btnMin.addEventListener
    # for
    ajaxDishReset = (dishid, o2uNum, successCallback, errorCallback) ->
      params =
        product_id: dishid
        quantity: o2uNum

      _doAjax "/westore/stores/add_item", "GET", params, (ret) ->
        unless ret["code"] is 0
          errorCallback()
          alert ret["message"]
          return
        else
          successCallback()
        return

      return
    # ajaxDishReset
    ajaxDishRemove = (dishid, successCallback, errorCallback) ->
      params =
        product_id: dishid

      _doAjax "/westore/stores/add_item", "GET", params, (ret) ->
        unless ret["code"] is 0
          errorCallback()
          alert ret["message"]
          return
        else
          successCallback()
        return

      return
    btn = _qAll("article dl .btn")
    btnIndex = 0
    btnLength = btn.length
    btnIndex
    while btnIndex < btnLength
      countNumText = parseInt(btn[btnIndex].children[1].innerHTML)
      btnAdd = btn[btnIndex].children[2]
      btnMin = btn[btnIndex].children[0]
      btnShowHide countNumText, btn[btnIndex], false
      iTimeout = undefined
      iInterval = undefined
      originalNum = undefined
      beforeRemoveDish = false
      beforeAddDish = false
      needRemoveNotify = false

      if btnAdd.nodeName.toUpperCase() == 'BUTTON'
        btnAdd.addEventListener _movestartEvt, ->
          _self = this
          originalNum = parseInt(_self.parentNode.children[1].innerHTML, 10)
          countNumText = originalNum + 1
          shopInfo = _self.parentNode.parentNode.getAttribute("shopInfo")
          if countNumText is 1
            if shopInfo
              _self.parentNode.children[1].innerHTML = 0
              beforeAddDish = true
              return
            else
              _self.parentNode.children[1].innerHTML = 1
              btnShowHide 1, _self.parentNode
          else
            _self.parentNode.children[1].innerHTML = countNumText
            btnShowHide countNumText, _self.parentNode
            iTimeout = setTimeout(->
              iInterval = setInterval(->
                countNumText++
                _self.parentNode.children[1].innerHTML = countNumText
                _removeClass _self.parentNode.children[3], "fake"
                _self.parentNode.children[3].innerHTML = countNumText
                return
              , 100)
              return
            , 1000)
          return

        btnAdd.addEventListener _moveendEvt, ->
          clearTimeout iTimeout
          clearInterval iInterval
          hideBigFont()
          _self = this
          countNumText = parseInt(_self.parentNode.children[1].innerHTML, 10)
          dishid = _self.parentNode.parentNode.getAttribute("dishid")
          shopInfo = _self.parentNode.parentNode.getAttribute("shopInfo")
          if beforeAddDish
            setTimeout (->
              MDialog.confirm "", shopInfo, null, "确定", (->
                _self.parentNode.children[1].innerHTML = 1
                btnShowHide 1, _self.parentNode
                ajaxDishReset dishid, 1, (->
                ), ->
                  _self.parentNode.children[1].innerHTML = originalNum
                  btnShowHide originalNum, _self.parentNode
                  return

                return
              ), null, "取消", (->
              ), null, null, true, true
              return
            ), 500
            beforeAddDish = false
          else
            ajaxDishReset dishid, countNumText, (->
            ), ->
              _self.parentNode.children[1].innerHTML = originalNum
              btnShowHide originalNum, _self.parentNode
              return
          getItemsCount()
          return

      btnMin.addEventListener _movestartEvt, ->
        _self = this
        originalNum = parseInt(_self.parentNode.children[1].innerHTML, 10)
        countNumText = originalNum - 1
        if countNumText <= 0
          _self.parentNode.children[1].innerHTML = 1
          beforeRemoveDish = true
          return
        else
          _self.parentNode.children[1].innerHTML = countNumText
          iTimeout = setTimeout(->
            iInterval = setInterval(->
              countNumText--
              if countNumText <= 0
                clearInterval iInterval
                _self.parentNode.children[1].innerHTML = 1
                beforeRemoveDish = true
                return
              else
                _self.parentNode.children[1].innerHTML = countNumText
                btnShowHide countNumText, _self.parentNode
              _removeClass _self.parentNode.children[3], "fake"
              _self.parentNode.children[3].innerHTML = countNumText
              return
            , 100)
            return
          , 1000)
        return

      btnMin.addEventListener _moveendEvt, ->
        clearTimeout iTimeout
        clearInterval iInterval
        hideBigFont()
        _self = this
        countNumText = parseInt(_self.parentNode.children[1].innerHTML, 10)
        dishid = _self.parentNode.parentNode.getAttribute("dishid")
        dName = _self.parentNode.parentNode.getAttribute("dName")
        if beforeRemoveDish
          if needRemoveNotify
            setTimeout (->
              MDialog.confirm "", "是否删除" + dName + "？", null, "确定", (->
                _self.parentNode.children[1].innerHTML = 0
                btnShowHide 0, _self.parentNode
                ajaxDishRemove dishid, (->
                ), ->
                  _self.parentNode.children[1].innerHTML = originalNum
                  btnShowHide originalNum, _self.parentNode
                  return

                return
              ), null, "取消", (->
                _self.parentNode.children[1].innerHTML = originalNum
                btnShowHide originalNum, _self.parentNode
                return
              ), null, null, true, true
              return
            ), 500
            beforeRemoveDish = false
          else
            _self.parentNode.children[1].innerHTML = 0
            btnShowHide 0, _self.parentNode
            ajaxDishRemove dishid, (->
            ), ->
              _self.parentNode.children[1].innerHTML = originalNum
              btnShowHide originalNum, _self.parentNode
              return

            beforeRemoveDish = false
        else
          ajaxDishReset dishid, countNumText, (->
          ), ->
            _self.parentNode.children[1].innerHTML = originalNum
            btnShowHide originalNum, _self.parentNode
            return
        getItemsCount()
        return

      btnIndex++
    return
  # ajaxDishRemove
  # doSelectBtn
  hideBigFont = ->
    _arr = _qAll(".fixBig")
    _forEach _arr, (ele, idx, _arr) ->
      _addClass ele, "fake"
      return

    return
  btnShowHide = (num, btns, isCountDish) ->
    if $('#navBar').length
      countDish()  if isCountDish isnt false
    if num <= 0
      btns.children[0].style.display = "none"
      btns.children[1].style.display = "none"
    else
      btns.children[0].style.display = "inline-block"
      btns.children[1].style.display = "inline-block"
    return
  countDish = ->
    countTotle = 0
    countdish = undefined
    dishNum = _qAll("#page_allMenu section article dl .btn i")
    _forEach dishNum, (ele, idx, dishNum) ->
      countdish = parseInt(ele.innerHTML)
      countTotle++  if countdish > 0
      return

    unless countTotle is 0
      _q("#page_allMenu nav dl dd.active span").innerHTML = countTotle
      _q("#page_allMenu nav dl dd.active span").style.display = "block"
    else
      _q("#page_allMenu nav dl dd.active span").style.display = "none"
    return

  #点击促发弹层事件
  # showPicInfo = ->
  #   links = _qAll(".dataIn")
  #   i = 0
  #   i
  #   while i < links.length
  #     links[i].onclick = (event) ->
  #       event.stopPropagation()

  #       # dl
  #       parentDl = @parentNode.parentNode
  #       childImg = @childNodes[0]
  #       childImg = @childNodes[1]  if childImg.nodeType is 3
  #       popPic childImg.src, parentDl.getAttribute("dname"), parentDl.getAttribute("dprice") + "元/" + parentDl.getAttribute("dunitName"), parentDl.getAttribute("dIsSpecial"), parentDl.getAttribute("dSpecialPrice") + "元/" + parentDl.getAttribute("dunitName"), parentDl.getAttribute("dsubCount"), parentDl.getAttribute("dtaste"), parentDl.getAttribute("ddescribe"), parentDl.getAttribute("dishot")
  #       return
  #     i++
  #   return

  #后台可自行扩展参数
  #调用自定义弹层
  popPic = (imgUrl, title, price, isSpecial, specialPrice, people, teast, assess, isHot) ->
    _title = title
    _price = price
    _people = people
    _teast = teast
    _assess = assess
    hotHtml = ""
    hotHtml = "<b></b>"  if isHot is view_const_dish_HOT_YES
    _tmpHtml = "<div class='content'>" + hotHtml + "<img src='" + imgUrl + "' alt='' title=''><h2>" + _title
    if isSpecial is view_const_dish_SPECIAL_PRICE_YES or isSpecial is view_const_dish_SPECIAL_PRICE_VIP
      _tmpHtml += "<i>" + specialPrice + "</i><del>" + _price + "</del>"
    else
      _tmpHtml += "<i>" + _price + "</i>"
    _tmpHtml += "<span>" + _people + "人点过</span>"  if _people
    _tmpHtml += "</h2>"
    _tmpHtml += "<h3>口味：" + _teast + "</h3>"  if _teast
    _tmpHtml += "<p>" + _assess + "</p>"  if _assess
    _tmpHtml += "</div>"
    MDialog.popupCustom _tmpHtml, true, (->
    ), true
    return


  # 获取各个分类被选中菜品的数量
  getDishNumOfCategory = ->
    params =
      order_id: order_id

    _doAjax "/westore/orders/categories_counter", "GET", params, (ret) ->
      return  unless ret["code"] is 0
      for i of ret["result"]["data"]
        val = ret["result"]["data"][i]
        if val > 0
          _q("[categoryId=\"" + i + "\"] span").innerHTML = val
          _q("[categoryId=\"" + i + "\"] span").style.display = "block"
        else
          _q("[categoryId=\"" + i + "\"] span").style.display = "none"
      return

    return

  getItemsCount = ->
    count = 0
    if $('#navBar').length
      $('#navBar').find('dd span:visible').each ->
        num = parseInt $(this).text()
        count += num
        $("#num").text(count)
    else
      count = $('dd.btn').find('i:visible').length
      $("#num").text(count)
    return

  order_id = $('#my_menu').data('order-id')
  view_const_dish_SPECIAL_PRICE_YES = "2"
  view_const_dish_SPECIAL_PRICE_VIP = "3"
  view_const_dish_HOT_YES = "2"

  _onPageLoaded ->
    if $('#navBar').length
      setHeight()
      doSelect()
      getDishNumOfCategory()
    doSelectBtn()
    #showPicInfo()
    if _isIOS
      _q("#page_allMenu section article").style.overflowY = "scroll"
      _q("#page_allMenu section article").style.minHeight = "85%"
      _q("#page_allMenu section article").style.marginBottom = "15px"

    return


  #setInterval(function(){
  #                getDishNumOfCategory();
  #            }, 5000);
  window.addEventListener "orientationchange", ->
    setHeight()
    return
