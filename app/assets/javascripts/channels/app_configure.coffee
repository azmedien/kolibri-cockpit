App.app_configure = App.cable.subscriptions.create "AppConfigureChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('#notifications').prepend(data.html);
