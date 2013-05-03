$ ->
  $.contextMenu
    selector: ".context-menu-one"
    callback: (key, options) ->
      m = "global: " + key
      window.console and console.log(m) or alert(m)

    items:
      add_feature:
        name: "Add Feature"
        
        callback: (key, options) ->
          m = "Clicked Add Features"
          window.G.load_features_form_with_seq(window.getSelection().toString())


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
