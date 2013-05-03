# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require autosave

window.G or= {}

window.G.begin_editing = (editor_selector, autosave_selector) ->
  $(autosave_selector).hide()
  setup_features()
  if not doc? or doc == ""
    notify "Unable to load file", "error"

  console.groupCollapsed("Preparing to edit a file")

  if window.isRestore
    console.groupCollapsed("An autosaved version exists")
    $(autosave_selector).show()
    G.Autosave.handle(editor_selector, autosave_selector, ->
      G.begin_editing(editor_selector, autosave_selector))
    console.groupEnd()
  else

    # G.debug_editor = new G.GorillaEditor(autosave_selector)
    G.main_editor = new G.GorillaEditor(editor_selector, doc, G.debug_editor)

    G.Autosave.start(G.main_editor)

    bind_features()
    bind_selections()

    G.main_editor.startEditing()
  console.groupEnd()
