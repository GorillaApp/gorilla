$ ->
  $.contextMenu
    selector: ".context-menu-one"
    callback: (key, options) ->
      m = "clicked: " + key
      window.console and console.log(m) or alert(m)

    items:
      edit:
        name: "Edit"

      cut:
        name: "Cut"

      copy:
        name: "Copy"

      paste:
        name: "Paste"

      delete:
        name: "Delete"

      sep1: "---------"
      quit:
        name: "Quit"

  $(".context-menu-one").on "click", (e) ->
    console.log "clicked", this