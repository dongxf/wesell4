//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require westore/share
//= require westore/wei_webapp_v2_common_v1.9.4
//= require westore/wei_dialog_v1.9.9
//= require westore/store
//= require westore/wesell_item

$(document).ready(function () {
  $('#more_info img').addClass('img-responsive');
  $(document).scroll(function() {
    var y = $(this).scrollTop();
    if (y > 200) {
      $('#back_to_top').fadeIn();
    } else {
      $('#back_to_top').fadeOut();
    }
  })

  $(document).ajaxStart(function () {
    $('.loading').show();
  });

  $(document).ajaxComplete(function () {
    $('.loading').hide();
  });
})
