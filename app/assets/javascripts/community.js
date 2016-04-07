//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require respond
//= require community/share
//= require summernote.min
//= require summernote-zh-CN
//= require lib/picker
//= require lib/picker.date
//= require lib/picker.time
//= require lib/zh_CN

function sendFile(file, editor, welEditable) {
    data = new FormData();
    data.append("file", file);
    $.ajax({
        data: data,
        type: "POST",
        url: "/pictures",
        cache: false,
        contentType: false,
        processData: false,
        beforeSend: function() {
          $('.loader').show();
        },
        success: function(pic) {
            picture = JSON.parse(pic);
            editor.insertImage(welEditable, picture.url);
        },
        complete: function() {
          $('.loader').hide();
        }
    });
}

$(document).ready(function(){
	var screenWidth = $(window).width();
	var tagWidth = $('.tag').width();
	var firstColumnTagLeft = 15;
  var SecColumnTagLeft   = firstColumnTagLeft + tagWidth
  var ThirdColumnTagLeft = firstColumnTagLeft + 2 * tagWidth - 1

  $('.sub_tags').css("width", screenWidth);
  $('.sub_tags').each(function(index) {
  	if (index%3 === 0) {
  		$(this).css("left", -firstColumnTagLeft);
  	} else if (index%3 == 1) {
  		$(this).css("left", -SecColumnTagLeft);
  	} else if (index%3 == 2) {
  		$(this).css("left", -ThirdColumnTagLeft);
  	}
  });
  $('.collapse').on('hidden.bs.collapse', function () {
    $('.wrapper').removeClass('active');
  });

  $('a.wrapper').on('click', function(e) {
      e.preventDefault();
      $('#tags').find('.in').collapse('toggle');
      var $this = $(this);
      var $collapse = $this.closest('.collapse-group').find('.collapse');
      $collapse.collapse('toggle');
      $collapse.on('shown.bs.collapse', function () {
        $this.addClass('active');
      });

      var tag_id;
      tag_id = $this.attr('id').split('-')[1];
      return $.ajax({
        url: '/community/tags/'+tag_id,
        type: 'PATCH',
        success: function() {
          console.log('tag'+tag_id+' click_count + 1');
        }
      });
  });

  $('.sub_tag_link').click(function() {
    var $this, sub_tag_id;
    $this = $(this);
    sub_tag_id = $this.attr('id').split('-')[1];
    return $.ajax({
      url: '/community/sub_tags/'+sub_tag_id,
      type: 'PATCH',
      success: function() {
        console.log('sub_tag'+sub_tag_id+' click_count + 1');
      }
    });
  });

  $('.page img').addClass('img-responsive');


  // $('#wechat').on('click', function() {
  //   WeixinJSBridge.call('closeWindow');
  // });
  $("#westore").tooltip();
  $("#wechat").tooltip();

  $(".for-record").on('click', function() {
    var id = $(this).data("id");
    $.ajax({
        type: "PATCH",
        url: "/community/village_items/"+id+"/count",
        cache: false,
        contentType: false,
        processData: false
    });
  });

  $(".call-record").on('click', function() {
    var id = $(this).data("id");
    $.ajax({
        type: "PATCH",
        url: "/community/village_items/"+id+"/call_record",
        cache: false,
        contentType: false,
        processData: false
    });
  });

  $(".shop-record").on('click', function() {
    var id = $(this).data("id");
    $.ajax({
        type: "PATCH",
        url: "/community/village_items/"+id+"/shop_record",
        cache: false,
        contentType: false,
        processData: false
    });
  });

  $(".view-record").on('click', function() {
    var id = $(this).data("id");
    $.ajax({
        type: "PATCH",
        url: "/community/village_items/"+id+"/view_record",
        cache: false,
        contentType: false,
        processData: false
    });
  });

  $('form.create_village_item').submit(function(){
      $(this).find('input[type=submit]').attr('disabled', 'disabled');
  });

  if ($('#search .form-control').length > 0 && $('#search .form-control').val().length != 0) {
    $('#close').show();
  }

  $('#search .form-control').on('keyup', function() {
    $('#close').show();
  });

  $("#close").on('click', function() {
    $('#search .form-control').val('');
    $('#close').hide()
  })

  $(document).ajaxStart(function () {
    $('.loading').show();
  });

  $(document).ajaxComplete(function () {
    $('.loading').hide();
  });

  $(document).scroll(function() {
    var y = $(this).scrollTop();
    if (y > 200) {
      $('#back_to_top').fadeIn();
    } else {
      $('#back_to_top').fadeOut();
    }
  })

  if($('.offer_datepicker').length > 0) {
    $('.offer_datepicker').pickadate({
      format: 'yyyy-mm-dd',
      formatSubmit: 'yyyy-mm-dd',
      editable: true,
      min: true,
      hiddenPrefix: '',
      hiddenSuffix: ''
    });
  }

  // village_item page with richtext
  if ($('.page-area').length > 0) {
    $('.page-area').summernote({
      height: 500,
      toolbar: [
        ['style', ['style']],
        ['font', ['bold', 'italic', 'underline', 'clear']],
        // ['fontname', ['fontname']],
        // ['fontsize', ['fontsize']], Still buggy
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['table', ['table']],
        ['insert', ['link', 'picture']],
        ['view', ['fullscreen']],
        ['help', ['help']]
      ],
      lang: "zh-CN",
      onImageUpload: function(files, editor, welEditable) {
        if (files[0].size > 1024000) {
          alert("请上传小于1MB的图片");
        } else {
          sendFile(files[0], editor, welEditable);
        }
      }
    });
  }

  $('.close_back').on('click', function() {
    // 关闭窗口
    WeixinJSBridge.call('closeWindow');
  });

  $('#approved-pop').popover();

  $('.set_default').on('change click', function(e) {
    var $this, village_id;
    $this = $(this);

    village_id = $this.data('village-id');
    return $.get("/community/villages/" + village_id + "/set_default", function(data) {
      if (data.status === 'ok') {
        console.log('ok');
      } else {
        console.log('not ok');
      }
    });
  });

  $('.check_in_village').on({
    change: function(e) {
      var $this, joined, instance_id, village_id, village_item_id;
      $this = $(this);
      joined = $this.attr('checked');
      instance_id = $this.data('instance-id');
      village_id = $this.data('village-id');
      village_item_id = $this.data('village-item-id');
      return $.get("/community/village_items/" + village_item_id + "/join?village_id=" + village_id+"&joined="+joined, function(data) {
        if (data.status === 'ok') {
          console.log('ok');
        } else {
          console.log('not ok');
        }
      });
    }
  });

  // $('.tag .wrapper').on({
  //   click: function(e) {
  //     var $this, tag_id;
  //     $this = $(this);
  //     tag_id = $this.attr('id').split('-')[1];
  //     return $.ajax({
  //       url: '/community/tags/'+tag_id,
  //       type: 'PATCH',
  //       success: function() {
  //         console.log('tag'+tag_id+' click_count + 1');
  //       }
  //     });
  //   }
  // });
});
