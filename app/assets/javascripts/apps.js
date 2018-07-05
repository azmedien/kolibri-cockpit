$(document).on("turbolinks:load", function() {
  return $('.jsoneditor-target').each(function() {
    var container, editor, target;
    target = $(this);
    container = $('<div class="jsoneditor-container">').insertAfter(target);
    editor = new JSONEditor(container[0], {
      modes: ['tree','code'],
      change: function() {
        return target.val(JSON.stringify(editor.get()));
      }
    });
    editor.set((function() {
      try {
        return JSON.parse(target.val());
      } catch (_error) {}
    })());
    return target.hide();
  });
});
