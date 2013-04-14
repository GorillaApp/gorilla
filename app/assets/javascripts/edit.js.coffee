# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

window.begin_editing = (editor_selector, autosave_selector) ->
  console.groupCollapsed("Preparing to edit a file")
  setup_features()

  if window.isRestore
    console.groupCollapsed("An autosaved version exists")
    Autosave.handle(editor_selector, autosave_selector, ->
      begin_editing(editor_selector, autosave_selector))
    console.groupEnd()
  else
    $(autosave_selector).hide()

    #window.debug_editor = new GorillaEditor(autosave_selector)
    window.main_editor = new GorillaEditor(editor_selector, doc)

    Autosave.start(main_editor)

    bind_features()

    main_editor.startEditing()
  console.groupEnd()
