#= require autosave

class window.GorillaEditor
  constructor: (@editorId, @initialDocument = '', @debugEditor = null) ->
    console.groupCollapsed("Initializing GorillaEditor: #{editorId}")
    if @initialDocument != ''
      @file = new GenBank(@initialDocument, @editorId[1..])
      if @debugEditor != null
        @debugEditor.file = new GenBank(@initialDocument, @debugEditor.editorId[1..])
        @debugEditor.startEditing()
    console.log("GorillaEditor ready!")
    console.groupEnd()

  viewFile: () ->
    console.groupCollapsed("Preparing Editor to be viewed")

    $(@editorId).html(@file.getAnnotatedSequence())
                .addClass('gorilla-editor viewing')

    console.log("Ready to view")
    console.groupEnd()

  startEditing: () ->
    console.groupCollapsed("Preparing Editor to be edited")
    me = @

    @viewFile()
    
    $(@editorId).attr('contenteditable','true')
                .attr('spellcheck','false')
                .removeClass('viewing')
                .addClass('editing')

    $(@editorId).find("*").andSelf()
                .unbind('keypress')
                .unbind('keydown')
                .unbind('keyup')
                .unbind('dragenter')
                .unbind('dragleave')
                .unbind('dragover')
                .unbind('drop')

    $(@editorId).bind('input', (event) -> me.textChanged(event))
                .keypress((event) -> me.keyPressed(event))
                .keydown((event) -> me.keyDown(event))
                .keyup((event) -> me.keyUp(event))
                .bind('dragenter', (event) -> event.preventDefault())
                .bind('dragleave', (event) -> event.preventDefault())
                .bind('dragover', (event) -> event.preventDefault())
                .bind('drop', (event) -> event.preventDefault())

    @editorContents = $(@editorId).text()
    @editorHtml = $(@editorId).html()
    @previousEditors = []
    @nextEditors = []
    @previousFiles = []
    @nextFiles = []
    console.log("Editor ready!")
    console.groupEnd()

  undo: (event) ->
    if @previousFiles.length > 0
      Autosave.request(this)
      @nextFiles.push($.extend(true, {}, @file))
      @file = @previousFiles.pop()
      $(@editorId).html(@file.getAnnotatedSequence())
      @completeEdit()

  redo: (event) ->
    if @nextFiles.length > 0
      Autosave.request(this)
      @previousFiles.push($.extend(true, {}, @file))
      @file = @nextFiles.pop()
      $(@editorId).html(@file.getAnnotatedSequence())
      @completeEdit()
      
  trackChanges: ->
    Autosave.request(this)
    @previousFiles.push($.extend(true, {}, @file))

  completeEdit: ->
    @file.updateSequence($(@editorId).text())
    if @debugEditor != null
      @debugEditor.file = new GenBank(@file.serialize())
      @debugEditor.viewFile()

  deleteAtCursor: (key = "<backspace>") ->
    sel = window.getSelection()

    console.log sel

    if sel.isCollapsed
      @trackChanges()

      loc = sel.getRangeAt(0)

      caretPosition = loc.startOffset

      element = loc.startContainer
      pe = element.parentNode

      removedChar = caretPosition - 1
      if key == "<delete>"
        removedChar = caretPosition
      element.deleteData(removedChar, 1)
      
      if pe.tagName == "SPAN"
        spl = pe.id.split('-')
        featureId = parseInt(spl[1])
        rangeId = parseInt(spl[2])
        @file.moveEndBy(featureId, rangeId, -1)
        node = pe.nextSibling
      else
        node = element
      while !!node
        if node.tagName == "SPAN"
          spl = node.id.split('-')
          featureId = parseInt(spl[1])
          rangeId = parseInt(spl[2])
          @file.advanceFeature(featureId, rangeId, -1)
        node = node.nextSibling

      sel.removeAllRanges()
      
      delme = null

      l = document.createRange()
      if removedChar - 1 == 0
        if element.tagName != "SPAN" and element.parentNode.id != $(@editorId).attr('id')
          element = element.parentNode
        if element.innerHTML?.length == 0
          delme = element
        element = element.previousSibling
        if element.tagName == "SPAN"
          element = element.childNodes[0]
        caretPosition = element.length + 1
      l.setStart(element, removedChar)
      l.collapse(true)

      if delme != null
        $(delme).remove()

      sel.addRange l

      @completeEdit()
    else
      console.error "How Dare You"

  keyDown: (event) ->
    if event.keyCode == 8
      console.groupCollapsed("Handling Backspace")
      event.preventDefault()
      @deleteAtCursor('<backspace>')
    else if event.keyCode == 46
      console.groupCollapsed("Handling Delete")
      event.preventDefault()
      @deleteAtCursor('<delete>')
    else if event.ctrlKey
      console.log(event)
      if event.keyCode == 90
        event.preventDefault()
        console.groupCollapsed("Handling Undo")
        @undo()
      if event.keyCode == 89
        event.preventDefault()
        console.groupCollapsed("Handling Redo")
        @redo()
    else
      return
    console.groupEnd()

  keyUp: (event) ->

  keyPressed: (event) ->
    event.preventDefault()

    code = if event.keyCode then event.keyCode else event.which
    char = String.fromCharCode(code).toLowerCase()
    console.groupCollapsed("Handling Key: ", char)

    if "agtc".indexOf(char) != -1
      console.log("ooh, exciting!")
      sel = window.getSelection()

      if sel.isCollapsed
        @trackChanges()

        loc = sel.getRangeAt(0)

        caretPosition = loc.startOffset

        element = loc.startContainer
        pe = element.parentNode

        if caretPosition == 0
          if pe.tagName == "SPAN"
            element = pe
            pe = pe.parentNode
          pe.insertBefore(document.createTextNode(char), element)
        else if pe.tagName == "SPAN"
          # Parse feature information from span ID
          idSplit = pe.id.split('-')
          featureId = parseInt(idSplit[1])
          spanId = parseInt(idSplit[2])

          # We'll need this later
          featureLength = element.length

          # Split the text inside the span
          end = element.splitText(caretPosition)
          start = element

          # Remove end from parent element
          pe.removeChild(end)

          # Add the char as a new text node after the parent element
          tn = document.createTextNode(char)
          pe.parentNode.insertBefore(tn, pe.nextSibling) # this is retarded

          if caretPosition < featureLength
            # Split feature apart
            feat = @file.splitFeatureAt(featureId, spanId, caretPosition-1)

            # Populate new span with appropriate information
            newGuy = document.createElement("SPAN")
            newGuy.id = "#{feat.new.parameters['/label']}-#{feat.new.id}-#{spanId}-#{@file.id}"
            newGuy.className = "#{feat.new.parameters['/label']}-#{feat.new.id}"
            newGuy.setAttribute("style", pe.getAttribute('style'))
            newGuy.appendChild(end)
            pe.parentNode.insertBefore(newGuy, tn.nextSibling)

            # Update successive ranges if there are more than one.
            for range in feat.new.location.ranges[1..]
              oldNode = document.getElementById("#{feat.new.parameters['/label']}-#{feat.old.id}-#{range.id}")
              oldNode.id = "#{feat.new.parameters['/label']}-#{feat.new.id}-#{range.id}"
              oldNode.className = "#{feat.new.parameters['/label']}-#{feat.new.id}"

          element = tn
        else
          end = element.splitText(caretPosition)
          start = element

          pe.removeChild(end)

          tn = document.createTextNode(char)

          pe.insertBefore(tn, start.nextSibling)
          pe.insertBefore(end, tn.nextSibling)
         
          element = tn

        node = element
        while !!node
          if node.tagName == "SPAN"
            spl = node.id.split('-')
            featureId = parseInt(spl[1])
            rangeId = parseInt(spl[2])
            @file.advanceFeature(featureId, rangeId, 1)
          node = node.nextSibling

        @completeEdit()

        sel.removeAllRanges()

        l = document.createRange()
        l.setStart(element, 1)
        l.collapse(true)

        sel.addRange l
      else
        console.error "I don't know how to handle this responsibility"

    console.groupEnd()

  textChanged: (event) ->
    console.error "contenteditable input event was fired"
