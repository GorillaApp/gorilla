window.handle_autosave = (editor_selector, autosave_selector) ->
  if doc_restored != null and doc != doc_restored
    recover_autosave = confirm("You may have closed this file without saving. Would you like to recover your changes?")

    if recover_autosave
      main_editor = new GorillaEditor(editor_selector, doc)
      main_editor.viewFile()
      autosave_editor = new GorillaEditor(autosave_selector, doc_restored)
      autosave_editor.viewFile()

      $(editor_selector).css("width", "45%")
                        .css("float", "left")
      $(autosave_selector).css("width", "45%")
                          .css("float", "left")

      $(".editor_labels").show()
      $("#autosavechoice").show()
      return
  isRestore = false
  begin_editing(editor_selector, autosave_selector)
