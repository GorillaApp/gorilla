window.handle_autosave = (editor_selector, autosave_selector) ->
  d = new GenBank(doc)
  dr = new GenBank(doc_restored)

  if doc_restored != null and d.getAnnotatedSequence() != dr.getAnnotatedSequence()

    recover_autosave = confirm("You may have closed this file without saving. Would you like to recover your changes?")

    if recover_autosave
      main_editor = new GorillaEditor(editor_selector, doc)
      main_editor.viewFile()
      autosave_editor = new GorillaEditor(autosave_selector, doc_restored)
      autosave_editor.viewFile()

      $(".editor_label").show()
      $("#autosavechoice").show()
      $('#opened').click ->
        window.isRestore = false
        begin_editing(editor_selector, autosave_selector)
      $('#autosaved').click ->
        window.doc = window.doc_restored
        window.isRestore = false
        begin_editing(editor_selector, autosave_selector)
      return
  window.isRestore = false
  begin_editing(editor_selector, autosave_selector)

window.autosave_file = (file) ->
  $.post "/edit/autosave",
         genbank_file: file.serialize()
         id: first_line
         user: user,
         (-> notify('Autosave Successful'))

window.delete_autosave = () ->
  $.post "/edit/delete",
         id: first_line,
         (-> notify("Delete Successful"))

window.start_autosaving = (editor) ->
  $('#autosave').click ->
    autosave_file(editor.file)

  $('#deleteAutosave').click ->
    delete_autosave()

  window.setInterval (-> autosave_file(editor.file)), 10000
