// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require respond
//= require summernote.min
//= require summernote-zh-CN
//= require react
//= require react_ujs
//= require components



function swing() {
	$('.fa-comments-o').toggleClass('animated swing');
}

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
	setInterval(swing, 3000);

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

  $("#submit_appointment").on('click', function(e){
    e.preventDefault();
    $(".qrcode").toggle();
  });
  $('.news img').addClass('img-responsive');
  $('#topic img').addClass('img-responsive');
})
