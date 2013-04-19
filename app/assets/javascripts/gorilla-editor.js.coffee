#= require genbank
#= require autosave
#= require util

window.G or= {}
Autosave = G.Autosave
GenBank = G.GenBank

window.G.GorillaEditor = class GorillaEditor
  constructor: (@mainId, @initialDocument = '', @debugEditor = null) ->
    console.groupCollapsed("Initializing GorillaEditor: #{@mainId}")
    $(@mainId).html('<div class="numbers"></div><div class="editor"></div><div style="clear:both;"></div>')
              .addClass('gorilla-container')
    @editorId = @mainId + ' .editor'
    @numbersId = @mainId + ' .numbers'
    if @initialDocument != ''
      @file = new GenBank(@initialDocument, @mainId[1..])
      if @debugEditor != null
        @debugEditor.file = new GenBank(@initialDocument, @debugEditor.editorId[1..])
        @debugEditor.startEditing()
    console.log("GorillaEditor ready!")
    console.groupEnd()

  viewFile: (render = true) ->
    console.groupCollapsed("Preparing Editor to be viewed")

    me = @

    $(@editorId).html(@file.getAnnotatedSequence())
                .addClass('gorilla-editor viewing')
                .find('span')
                .hover((event) -> me.showHoverDialog(event))
                .mousemove((event) -> me.showHoverDialog(event))

    if render
        @renderNumbers('viewing')
        $(window).resize((event) -> me.renderNumbers('viewing'))
    console.log("Ready to view")
    console.groupEnd()

  startEditing: () ->
    console.groupCollapsed("Preparing Editor to be edited")
    me = @

    @viewFile(false)
    @renderNumbers('editing')
    $(window).resize((event) -> me.renderNumbers('editing'))
    
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

  showHoverDialog: (event) ->
    if event.type == "mouseleave"
        $('#hover-box').remove()
        return
    if event.type == "mouseenter"
        data = GenBank.getSpanData(event.target)
        text = ""
        for featureId, content of data
            if text != ""
                text += '<br>'
            feat = @file.getFeatures()[featureId]
            text += feat.parameters['/label']
        node = $(event.target)
        newElement = $('<div>', id: 'hover-box')
        newElement.html(text)
        $('body').append(newElement)
    $('#hover-box').css('top', event.pageY + 10)
    $('#hover-box').css('left', event.pageX + 10)

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
      
  # this... This is horrific
  getCharsWide: (type) ->
    $('article').append($("""
    <div id="get-chars-wide-gorilla">
        <div class="numbers"></div>
        <div class="editor" contenteditable="true"></div>
        <div style="clear:both;"></div>
    </div>"""))
    $('#get-chars-wide-gorilla').addClass('gorilla-container')
    $('#get-chars-wide-gorilla .editor').addClass("gorilla-editor #{type}")

    $('#get-chars-wide-gorilla .numbers').html('1<br>2')
    node = $('#get-chars-wide-gorilla .editor')
    txt = 'a'
    node.text(txt)
    hei = node.height()
    while hei >= node.height() and txt.length < 10000
        txt += 'a'
        node.text(txt)
    $('#get-chars-wide-gorilla').remove()
    return txt.length - 1

  renderNumbers: (type) ->
    $(@numbersId).html('1')
    chars = @getCharsWide(type)
    lines = $(@editorId).get(0).clientHeight / 16
    text = ''
    loc = 1
    for line in [0...lines]
        text += loc + '<br>'
        loc += chars
    $(@numbersId).html(text)

  trackChanges: ->
    @renderNumbers()
    Autosave.request(this)
    @previousFiles.push($.extend(true, {}, @file))

  completeEdit: ->
    @file.updateSequence($(@editorId).text())
    if @debugEditor != null
      @debugEditor.file = new G.GenBank(@file.serialize())
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

      if key == "<delete>"
        console.log element.length, caretPosition
        if element.length <= caretPosition
            caretPosition = 0
            if pe.tagName == "SPAN"
                element = pe
            element = element.nextSibling
            pe = element.parentNode
            while element.nodeName == "#text" and element.length == 0
                element = element.nextSibling
            if element.tagName == "SPAN"
                pe = element
                element = pe.firstChild

      removedChar = caretPosition - 1
      if key == "<delete>"
        removedChar = caretPosition
      element.deleteData(removedChar, 1)
      
      if pe.tagName == "SPAN"
        console.log 'caretPosition',caretPosition
        data = GenBank.getSpanData(pe)
        for featureId, content of data
            @file.moveEndBy(featureId, content.span, -1)
        node = pe.nextSibling
      else
        node = element

      while !!node
        if node.tagName == "SPAN"
          data = GenBank.getSpanData(node)
          for featureId, content of data
              if content.offset == 0
                  @file.advanceFeature(featureId, content.span, -1)
        node = node.nextSibling

      sel.removeAllRanges()
      
      delme = null

      l = document.createRange()
      console.log removedChar
      if removedChar == 0
        if element.tagName != "SPAN" and element.parentNode.id != $(@editorId).attr('id')
          element = element.parentNode
        if element.innerHTML?.length == 0
          delme = element
        element = element.previousSibling
        if element.tagName == "SPAN"
          element = element.childNodes[0]
          caretPosition = element.length
        l.setStart(element, caretPosition)
      else
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
    char = String.fromCharCode(code)
    console.groupCollapsed("Handling Key: ", char)

    if "agtcnACTGN".indexOf(char) != -1
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
          offsets = pe.getAttribute('data-offsets').split(',')
          features = pe.getAttribute('data-features').split(',')
          data = {}
          for offset in offsets
              split = offset.split(':')
              data[split[0]] or= {}
              data[split[0]]['offset'] = parseInt(split[1])
          for feature in features
              split = feature.split(':')
              data[split[0]] or= {}
              data[split[0]]['span'] = parseInt(split[1])

          console.log data

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
            data_features = ""
            data_offsets = ""
            featuresAffected = []
            for featureId, content of data
                if data_features != ""
                    data_features += ","
                    data_offsets += ","
                feat = @file.splitFeatureAt(featureId, content.span, content.offset + caretPosition - 1)
                featuresAffected.push(feat)
                data_features += "#{feat.new.id}:#{content.span}"
                data_offsets += "#{feat.new.id}:0"

            # Populate new span with appropriate information
            newGuy = document.createElement("SPAN")
            newid = $(@editorId).find('span').length
            newGuy.id = "#{newid}-#{@file.id}"
            newGuy.setAttribute("style", pe.getAttribute('style'))
            newGuy.setAttribute("data-offsets", data_offsets)
            newGuy.setAttribute("data-features", data_features)
            newGuy.appendChild(end)
            pe.parentNode.insertBefore(newGuy, tn.nextSibling)

            # Update successive ranges if there are more than one.
            node = tn
            while !!node
                if node.tagName == "SPAN"
                    features = node.getAttribute('data-features').split(',')
                    offsets = node.getAttribute('data-offsets').split(',')
                    feats = []
                    offs = []
                    for feature in features
                        split = feature.split(':')
                        for feat in featuresAffected
                            if parseInt(split[0]) == feat.old.id
                                split[0] = feat.new.id
                        feats.push(split.join(':'))
                    node.setAttribute('data-features', feats.join(','))
                    
                    for offset in offsets
                        split = offset.split(':')
                        for feat in featuresAffected
                            if parseInt(split[0]) == feat.old.id
                                split[0] = feat.new.id
                                split[1] = parseInt(split[1]) - caretPosition - data[feat.old.id].offset
                        offs.push(split.join(':'))
                    node.setAttribute('data-offsets', offs.join(','))
                node = node.nextSibling
          element = tn
        else
          end = element.splitText(caretPosition)
          start = element

          pe.removeChild(end)

          tn = document.createTextNode(char)

          pe.insertBefore(tn, start.nextSibling)
          pe.insertBefore(end, tn.nextSibling)
         
          element = tn

        advancedFeatures = {}
        node = element
        while !!node
          if node.tagName == "SPAN"
            data = GenBank.getSpanData(node)

            for featureId, content of data
                rangeId = content.span
                advancedFeatures[featureId] or= {}
                if advancedFeatures[featureId][rangeId] == undefined
                    advancedFeatures[featureId][rangeId] = true
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
