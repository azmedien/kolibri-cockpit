//
$(document).on("turbolinks:load", function() {
  $.each($('.preload'), function(index, obj){
    var img = new Image();
    img.src = $(obj).attr('data-source');

    $(img).ready(function(){
      $(obj).attr('src', img.src);
    })
  })
});
