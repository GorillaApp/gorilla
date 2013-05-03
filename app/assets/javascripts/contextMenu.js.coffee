$ ->
  $.contextMenu
    selector: '.editor.gorilla-editor'
    callback: (key, options) ->
      m = "global: " + key
      window.console and console.log(m) or alert(m)
    build: ->
      window.textSelString = window.getSelection().toString()
      window.textSel = window.G.Mouse.getCursorPosition()

    items:
      add_feature:
        name: "Add Feature"
        
        callback: (key, options) ->
          m = "Clicked Add Features" 
          console.log(window.textSel)
          window.G.load_features_form_with_seq(window.textSelString)

      rev_comp:
        name: "Reverse Complement"

        callback: (key, options) ->
          window.G.modifySelection(window.G.reverseCompSelection, window.textSel)

      to_upper:
        name: "To Uppercase"

        callback: (key, options) ->
          window.G.modifySelection(window.G.toUpper, window.textSel)

      to_lower:
        name: "To Lowercase"

        callback: (key, options) ->
          window.G.modifySelection(window.G.toLower, window.textSel)

      sep1: "---------"
      cut:
        name: "Cut"

      copy:
        name: "Copy"

      paste:
        name: "Paste"