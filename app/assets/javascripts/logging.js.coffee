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
    @entryAnnounced = true
    @exitAnnounced = true

  announceEntry: () ->
    if !@entryAnnounced
      @entryAnnounced = true
      for i in [0...@indentor.length]
        console.log(@pre + "\\")
        @pre += @indentor[i]

  enter: () ->
    @entryAnnounced = false

  announceExit: () ->
    if !@exitAnnounced
      @exitAnnounced = true
      for i in [0...@indentor.length]
        @pre = @pre[...-1]
        console.log(@pre + "/")

  exit: () ->
    @exitAnnounced = !@entryAnnounced
    @entryAnnounced = true
    

  say: (text) ->
    @announceEntry()
    @announceExit()
    console.log (@pre + text) if typeof(text) == "string"
    console.log (text) if typeof(text) != "string"

  d: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.DEBUG
      @say(text)

  l: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.LOG
      @say(text)

  w: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.WARN
      @say(text)

  e: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.ERROR
      @say(text)

  wtf: (text, flag = lc.ALL) ->
    if (flag & @flags) != 0 and @minLevel <= ll.WHAT_A_TERRIBLE_FAILURE
      @say(text)
