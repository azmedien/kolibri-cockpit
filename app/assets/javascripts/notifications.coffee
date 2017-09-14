$ ()->
  $("form.new_building").on "ajax:success", (event, data, status, xhr) ->
    $("form.new_building")[0].reset()
    $('#new-building-modal').modal('hide')
    fulladdress = "#{data.address} (#{data.name}, #{data.city}, #{data.zip})"
    $('#tour_building_tokens').tokenInput("add", {id: data.id, address: fulladdress} )
    $('#error_explanation').hide()

  $("form.new_building").on "ajax:error", (event, xhr, status, error) ->
    errors = jQuery.parseJSON(xhr.responseText)
    errorcount = errors.length
    $('#error_explanation').empty()
    if errorcount > 1
      $('#error_explanation').append('<div class="alert alert-error">The form contains ' + errorcount + ' errors.</div>')
    else
      $('#error_explanation').append('<div class="alert alert-error">The form contains 1 error</div>')
    $('#error_explanation').append('<ul>')
    for e in errors
      $('#error_explanation').append('<li>' + e + '</li>')
    $('#error_explanation').append('</ul>')
    $('#error_explanation').show()
