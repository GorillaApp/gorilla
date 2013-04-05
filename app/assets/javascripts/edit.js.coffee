# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

window.begin_editing = (editor_selector, autosave_selector) ->
  $('#autosavechoice').hide()

  if isRestore
    handle_autosave(editor_selector, autosave_selector)

  window.main_editor = new GorillaEditor(editor_selector, doc)

  start_autosaving(main_editor)
  bind_features()

  main_editor.startEditing()

  $('#addFeature')
