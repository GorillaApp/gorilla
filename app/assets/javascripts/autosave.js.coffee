window.G or= {}

window.G.Autosave = class Autosave
  @SHOULD_AUTOSAVE: false
  @TIMEOUT_ID: -1

  @request: (editor) ->
    Autosave.SHOULD_AUTOSAVE = true
    if Autosave.TIMEOUT_ID != -1
      clearTimeout(Autosave.TIMEOUT_ID)
    Autosave.TIMEOUT_ID = setTimeout (-> Autosave.save(editor.file)), 1000

  @handle: (editor_selector, autosave_selector, callback) ->
    $("#autosavechoice").hide()
    $("#header_links").hide()
    d = new G.GenBank(doc)
    dr = new G.GenBank(doc_restored)

    if doc_restored != null and d.getAnnotatedSequence() != dr.getAnnotatedSequence()

      recover_autosave = confirm("You may have closed this file without saving. Would you like to recover your changes?")

      if recover_autosave
        main_editor = new G.GorillaEditor(editor_selector, doc)
        main_editor.viewFile()
        autosave_editor = new G.GorillaEditor(autosave_selector, doc_restored)
        autosave_editor.viewFile()

        $(".editor_label").show()
        $("#autosavechoice").show()
        $('#opened').click ->
          window.isRestore = false
          callback()
          $("#header_links").show()
        $('#autosaved').click ->
          window.doc = window.doc_restored
          window.isRestore = false
          callback()
          $("#header_links").show()
        return
      else
        Autosave.delete()
        $("#header_links").show()
    window.isRestore = false
    callback()

  @save: (file) ->
    if Autosave.SHOULD_AUTOSAVE
      $.post "/edit/autosave",
             genbank_file: file.serialize()
             id: first_line
             user: user,
             ->
               notify('Autosave Successful', 'status', 1000)
               Autosave.SHOULD_AUTOSAVE = false

  @delete: () ->
    $.post "/edit/delete",
           id: first_line,
           user: user,
           ->
              notify("Delete Successful", 'status', 1000)

  @start: (editor) ->
    $("#autosavechoice").hide()

    $('#autosave').click ->
      Autosave.request(editor)
      Autosave.save(editor.file)

    $('#deleteAutosave').click ->
      Autosave.delete()

    # I'm not sure the below line is necessary because the GorillaEditor autosaves with each change
    # window.setInterval (-> Autosave.save(editor.file)), 10000
