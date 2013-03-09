window.lc =
  PARSE: 1
  RENDER: 2
  EDIT: 4
  ALL: -1

window.ll =
  DEBUG: 0
  LOG: 1
  WARN: 2
  ERROR: 3
  WHAT_A_TERRIBLE_FAILURE: 4

class window.Log
  constructor: (@flags, @minLevel) ->
    @pre = ""
    @indentor = "  "

  enter: () ->
    for i in [0...@indentor.length]
      console.log(@pre + "\\")
      @pre += @indentor[i]

  exit: () ->
    for i in [0...@indentor.length]
      @pre = @pre[...-1]
      console.log(@pre + "/")
    

  d: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.DEBUG
      console.log (@pre + text) if typeof(text) == "string"
      console.log (text) if typeof(text) != "string"

  l: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.LOG
      console.log (@pre + text) if typeof(text) == "string"
      console.log (text) if typeof(text) != "string"

  w: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.WARN
      console.log (@pre + text) if typeof(text) == "string"
      console.log (text) if typeof(text) != "string"

  e: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.ERROR
      console.log (@pre + text) if typeof(text) == "string"
      console.log (text) if typeof(text) != "string"

  wtf: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.WHAT_A_TERRIBLE_FAILURE
      console.log (@pre + text) if typeof(text) == "string"
      console.log (text) if typeof(text) != "string"
