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
