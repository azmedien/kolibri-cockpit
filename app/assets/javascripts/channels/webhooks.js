App.webhooks = App.cable.subscriptions.create('WebhooksChannel', {
  received: function(data) {
    if ($('tr#' + data.id).length == 0 ) {
      $('#builds').prepend(data.html);
    } else {
      $('tr#' + data.id).replaceWith(data.html);
    }
  }
});
