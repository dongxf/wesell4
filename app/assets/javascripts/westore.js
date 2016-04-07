//= require jquery
//= require jquery_ujs
//= require lib/picker
//= require lib/picker.date
//= require lib/picker.time
//= require lib/zh_CN
//= require westore/share
//= require westore/wei_webapp_v2_common_v1.9.4
//= require westore/wei_dialog_v1.9.9
//= require westore/store
//= require westore/datepicker
//= require westore/wesell_item
//=# require westore/order

$(document).ready(function () {
  $(document).ajaxStart(function () {
    $('.loading').show();
  });

  $(document).ajaxComplete(function () {
    $('.loading').hide();
  });
})
