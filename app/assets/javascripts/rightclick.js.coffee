$ ->
  $.contextMenu
    selector: ".context-menu-one"
    callback: (key, options) ->
      m = "clicked: " + key
      window.console and console.log(m) or alert(m)

    items:
      edit:
        name: "Edit"
        icon: "edit"

      cut:
        name: "Cut"
        icon: "cut"

      copy:
        name: "Copy"
        icon: "copy"

      paste:
        name: "Paste"
        icon: "paste"

      delete:
        name: "Delete"
        icon: "delete"

      sep1: "---------"
      quit:
        name: "Quit"
        icon: "quit"

  $(".context-menu-one").on "click", (e) ->
    console.log "clicked", this