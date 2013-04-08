class window.Mouse
  @setCursorAt: (id, location) ->
    sel = window.getSelection()
    node= document.getElementById(id).childNodes[0]
    sel.removeAllRanges()
    l = document.createRange()
    l.setStart node, location
    l.collapse true
    sel.addRange l

class window.Keyboard
  @type: (thing, type = "keypress", ctrl = false) ->
    if thing.charAt(0) == "<" and thing.charAt(thing.length - 1) == ">"
      switch thing
        when "<backspace>" then Keyboard._type_raw(8, "keydown")
        when "<undo>","<ctrl-z>"
          Keyboard._type_raw(90, "keydown", true)
        when "<redo>","<ctrl-y>"
          Keyboard._type_raw(89, "keydown", true)
    else if typeof thing == "number"
      Keyboard._type_raw(thing, type, ctrl)
    else if typeof thing == "string"
      for i in [0..thing.length]
        Keyboard._type_raw(thing.charCodeAt(i), type, ctrl)

  @_type_raw: (code, type = "keypress", ctrl = false) ->
    event = jQuery.Event(type, {keyCode:code,ctrlKey:ctrl})
    jQuery('#ed').trigger(event)
