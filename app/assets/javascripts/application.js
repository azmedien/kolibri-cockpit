// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jsoneditor
//= require jquery3
//= require jquery_ujs
//= require popper
//= require turbolinks
//= require_tree .
//= require bootstrap

$(document).on("turbolinks:load", function() {
  $('[data-toggle="tooltip"]').tooltip()
  $('.table tr[data-href]').each(function(){
        $(this).css('cursor','pointer').hover(
            function(){
                $(this).addClass('active');
            },
            function(){
                $(this).removeClass('active');
            }).click( function(){
                window.open($(this).attr('data-href'), '_blank');
            }
        );
    });
  $('.preload').each(function(index, obj){
    var img = new Image();
    img.src = $(obj).attr('data-source');

    $(img).ready(function(){
      $(obj).attr('src', img.src);
    });
  });
})
