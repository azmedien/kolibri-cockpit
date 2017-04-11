App.webhooks = App.cable.subscriptions.create('WebhooksChannel', {
  received: function(data) {
    if ($('#' + data.platform).find('tr#' + data.id).length == 0 ) {
      $('#' + data.platform).find('#builds').prepend(data.html);
    } else {
      $('#' + data.platform).find('tr#' + data.id).replaceWith(data.html);
    }
  }
});
