#= require mouse

window.G or= {}
Mouse = G.Mouse

class ContextMenu
  @bind: (selector = '#main_editor .editor', autosave = false) ->
    $.contextMenu
      selector: selector
      build: ->
        ContextMenu.textSelString = window.getSelection().toString()
        ContextMenu.textSel = Mouse.getCursorPosition()
        return true

      events:
        hide: ->
          sel = ContextMenu.textSel
          if sel.type == "range"
            Mouse.selectIndices(selector, sel.start, sel.end)
          delete ContextMenu.textSelString
          delete ContextMenu.textSel

      items:
        add_feature:
          name: "Add Feature"
          
          callback: (key, options) ->
            m = "Clicked Add Features"
            console.log(window.textSel)
            G.load_features_form_with_seq(ContextMenu.textSelString)

        rev_comp:
          name: "Reverse Complement"
          disabled: true
          callback: (key, options) ->
            G.modifySelection(G.reverseCompSelection, G.textSel)

        to_upper:
          name: "To Uppercase"
          disabled: autosave
          callback: (key, options) ->
            G.modifySelection(G.toUpper, true, ContextMenu.textSel)

        to_lower:
          name: "To Lowercase"
          disabled: autosave
          callback: (key, options) ->
            G.modifySelection(G.toLower, true, ContextMenu.textSel)

        sep1: "---------"
        cut:
          name: "Cut"
          disabled: true

        copy:
          name: "Copy"
          disabled: true

        paste:
          name: "Paste"
          disabled: true

G.ContextMenu = ContextMenu
