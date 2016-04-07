//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require respond
//= require lib/nested_form
//= require lib/select2.min
//= require lib/select2_locale_zh-CN
//= require lib/bootstrap-switch
//= require lib/bootstrap-editable
//= require lib/picker
//= require lib/picker.date
//= require lib/picker.time
//= require lib/zh_CN
//= require platform/wechat_menu
//= require platform/kategories
//= require platform/store
//= require platform/order_actions
//= require platform/customers
//= require platform/wesell_items
//= require platform/categories
//= require platform/editable
//= require platform/dashboard
//= require platform/villages
//= require chosen.jquery.min
//= require summernote.min
//= require summernote-zh-CN

//you should wirte coffee!
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


$(document).ready(function() {

  // wesell_item description with richtext
  $('.summernote').summernote({
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
      ['view', ['fullscreen', 'codeview']],
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

	// dashboard date-pick
	$('.datepicker').pickadate({
		format: 'yyyy-mm-dd',
		formatSubmit: 'yyyy-mm-dd',
		editable: true,
		max: true,
		hiddenPrefix: '',
		hiddenSuffix: '',
		onSet: function() {
      $('.pick-date').removeAttr('disabled');
      //all .pick-date ,but  should be $(this) to be specific
		}
	});

  // village_item datepicker
	$('.datepicker2').pickadate({
		format: 'yyyy-mm-dd',
		formatSubmit: 'yyyy-mm-dd',
		editable: true,
		hiddenPrefix: '',
		hiddenSuffix: ''
	});

	// progress bar
	$(document).ajaxStart(function () {
	    if ($("#progress").length === 0) {
	        $("body").append($("<div><dt/><dd/></div>").attr("id", "progress"));
	        $("#progress").width(Math.random() * 100 + "%");
	    }
	});

	$(document).ajaxComplete(function () {
	    $("#progress").width("101%").delay(200).fadeOut(400, function () {
	        $(this).remove();
	    });
	});

  $('.chosen-select').chosen().change(function() {
  	if($('.search-choice').length > 0) {
  		$('.submit_vi').removeAttr('disabled');
  	}
  });

  if ($('.search-choice').length > 0) {
  	$('.submit_vi').removeAttr('disabled');
  } else {
  	$('.submit_vi').attr('disabled', 'disabled');
  }

  $('form.reply').submit(function() {
    $(this).find('.submit_reply').attr('disabled', 'disabled');
  });

  $('#edit-village').on('click', function() {
  	$('.update_village').slideToggle();
  	$('.village-link').toggle();
  });

  $('#pin').popover();

  $('.check_in_village').on({
    change: function(e) {
      var $this, joined, instance_id, village_id, village_item_id;
      $this = $(this);
      joined = $this.attr('checked');
      instance_id = $this.data('instance-id');
      village_id = $this.data('village-id');
      village_item_id = $this.data('village-item-id');
      return $.get("/platform/instances/" + instance_id + "/village_items/" + village_item_id + "/join?village_id=" + village_id+"&joined="+joined, function(data) {
        if (data.status === 'ok') {
          console.log('ok');
        } else {
          console.log('not ok');
        }
      });
    }
  });
});
