class window.GorillaEditor
  constructor: (@editorId, @initialDocument = '', @debugEditor = null) ->
    logger.d("Initializing GorillaEditor...")
    if @initialDocument != ''
      @file = new GenBank(@initialDocument, @editorId[1..])
      if @debugEditor != null
        @debugEditor.file = new GenBank(@initialDocument, @debugEditor.editorId[1..])
        @debugEditor.startEditing()
    logger.d("GorillaEditor ready!")

  startEditing: () ->
    logger.d("Preparing Editor...")
    me = @
    
    $(@editorId).css("width", "90%")
                .css("marginLeft", "5%")
                .css("marginRight", "5%")
                .css("marginBottom", "2%")
                .css('word-wrap','break-word')
                .css('font-family','monospace')
                .attr('contenteditable','true')
                .attr('spellcheck','false')
                .html(@file.getAnnotatedSequence())

    $(@editorId).find("*").andSelf().unbind('keypress').unbind('keydown').unbind('keyup')

    $(@editorId).bind('input', (event) -> me.textChanged(event))
                .keypress((event) -> me.keyPressed(event))
                .keydown((event) -> me.keyDown(event))
                .keyup((event) -> me.keyUp(event))

    @editorContents = $(@editorId).text()
    @editorHtml = $(@editorId).html()
    @previousEditors = []
    @nextEditors = []
    @previousFiles = []
    @nextFiles = []
    logger.d("Editor ready!")

  undo: (event) ->
    if @previousFiles.length > 0
      @nextFiles.push($.extend(true, {}, @file))
      @file = @previousFiles.pop()
      $(@editorId).html(@file.getAnnotatedSequence())
      @updateDebugEditor()

  redo: (event) ->
    if @nextFiles.length > 0
      @previousFiles.push($.extend(true, {}, @file))
      @file = @nextFiles.pop()
      $(@editorId).html(@file.getAnnotatedSequence())
      @updateDebugEditor()
      
  trackChanges: ->
    @previousFiles.push($.extend(true, {}, @file))

  updateDebugEditor: ->
    if @debugEditor != null
      @file.updateSequence($(@editorId).text())
      @debugEditor.file = new GenBank(@file.serialize())
      @debugEditor.startEditing()

  deleteAtCursor: () ->
    sel = window.getSelection()

    logger.l sel

    if sel.type == "Caret"
      @trackChanges()

      loc = sel.getRangeAt(0)

      caretPosition = loc.startOffset

      element = loc.startContainer
      pe = element.parentNode

      element.deleteData(caretPosition-1, 1)
      
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
      if caretPosition - 1 == 0
        if element.tagName != "SPAN" and element.parentNode.id != $(@editorId).attr('id')
          element = element.parentNode
        if element.innerHTML?.length == 0
          delme = element
        element = element.previousSibling
        if element.tagName == "SPAN"
          element = element.childNodes[0]
        caretPosition = element.length + 1
      l.setStart(element, caretPosition-1)
      l.collapse(true)

      if delme != null
        $(delme).remove()

      sel.addRange l

      @updateDebugEditor()
    else
      logger.wtf "How Dare You"

  keyDown: (event) ->
    if event.keyCode == 8
      logger.l event
      logger.l "Backspace"
      event.preventDefault()
      event.stopPropagation()
      @deleteAtCursor()
    else if event.ctrlKey
      logger.l event
      if event.keyCode == 90
        @undo()
      if event.keyCode == 89
        @redo()

  keyUp: (event) ->

  keyPressed: (event) ->
    event.preventDefault()

    logger.enter()

    char = String.fromCharCode(event.keyCode).toLowerCase()
    if "agtc".indexOf(char) != -1
      logger.d "ooh, exciting!"
      sel = window.getSelection()

      if sel.type == "Caret"
        @trackChanges()

        loc = sel.getRangeAt(0)

        caretPosition = loc.startOffset

        element = loc.startContainer
        pe = element.parentNode

        if pe.tagName == "SPAN"
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
          tn = document.createTextNode()
          tn.textContent = char
          pe.parentNode.insertBefore(tn, pe.nextSibling) # this is retarded

          if caretPosition < featureLength
            # Split feature apart
            feat = @file.splitFeatureAt(featureId, spanId, caretPosition-1)

            # Populate new span with appropriate information
            newGuy = document.createElement("SPAN")
            newGuy.id = "#{feat.new.parameters['/label']}-#{feat.new.id}-#{spanId}-#{file.id}"
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

          tn = document.createTextNode()
          tn.textContent = char

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

        @updateDebugEditor()

        sel.removeAllRanges()

        l = document.createRange()
        l.setStartAfter(element)
        l.collapse(true)

        sel.addRange l
      else
        logger.wtf "I don't know how to handle this responsibility!"
    logger.exit()

  textChanged: (event) ->
    logger.wtf "NOOOOOOOOOOOOOOOOOOOOOOOO"
