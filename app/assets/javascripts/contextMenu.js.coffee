$ ->
  $.contextMenu
    selector: '.editor.gorilla-editor'
    callback: (key, options) ->
      m = "global: " + key
      window.console and console.log(m) or alert(m)
    build: ->
      window.textSel = window.getSelection().toString()
    items:
      add_feature:
        name: "Add Feature"
        
        callback: (key, options) ->
          m = "Clicked Add Features"
          window.G.load_features_form_with_seq(window.textSel)


      list_features:
        name: "List of Features"

      copy:
        name: "Copy"

      paste:
        name: "Paste"

      delete:
        name: "Delete"

      sep1: "---------"
      quit:
        name: "Quit"
