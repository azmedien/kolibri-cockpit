# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on "turbolinks:load", ->
  
  $('.jsoneditor-target').each ->

    target = $ this

    container = $('<div class="jsoneditor-container">')
      .insertAfter target

    editor = new JSONEditor container[0],
      modes: ['code', 'form', 'text', 'tree', 'view']
      change: ->
        target.val JSON.stringify editor.get()

    editor.set(
      try
        JSON.parse target.val()
    )

    target.hide()
