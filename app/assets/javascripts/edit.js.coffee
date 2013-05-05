#= require autosave
#= require contextMenu
#= require gorilla-editor

window.G or= {}
Autosave = G.Autosave
GorillaEditor = G.GorillaEditor
ContextMenu = G.ContextMenu

G.begin_editing = (editor_selector, autosave_selector) ->
  $(autosave_selector).hide()
  setup_features()
  if not doc? or doc == ""
    notify "Unable to load file", "error"
    return

  console.groupCollapsed("Preparing to edit a file")

  if window.isRestore
    console.groupCollapsed("An autosaved version exists")
    $(autosave_selector).show()
    Autosave.handle(editor_selector, autosave_selector, ->
      G.begin_editing(editor_selector, autosave_selector))
    ContextMenu.bind(editor_selector, true)
    ContextMenu.bind(autosave_selector, true)
    console.groupEnd()
  else
    ContextMenu.bind()

    # G.debug_editor = new G.GorillaEditor(autosave_selector)
    G.main_editor = new GorillaEditor(editor_selector, doc, G.debug_editor)

    Autosave.start(G.main_editor)

    bind_features()
    bind_selections()

    G.main_editor.startEditing()
  console.groupEnd()
