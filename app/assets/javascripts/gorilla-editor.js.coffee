#= require genbank
#= require autosave
#= require util
#= require mouse
#= require mousetrap
#= require mousetrap-global

window.G or= {}
Autosave = G.Autosave
GenBank = G.GenBank
Mouse = G.Mouse

window.G.GorillaEditor = class GorillaEditor
  @_editor_instances: {}

  constructor: (@mainId, @initialDocument = '', @debugEditor = null) ->
    console.groupCollapsed("Initializing GorillaEditor: #{@mainId}")
    $(@mainId).html('<div class="numbers"></div><div class="editor"></div><div style="clear:both;"></div>')
              .addClass('gorilla-container')
    GorillaEditor._editor_instances[@mainId[1..]] = @
    @editorId = @mainId + ' .editor'
    @numbersId = @mainId + ' .numbers'
    if @initialDocument != ''
      @file = new GenBank(@initialDocument, @mainId[1..])
      if @debugEditor != null
        @debugEditor.file = new GenBank(@initialDocument, @debugEditor.editorId[1..])
        @debugEditor.startEditing()
    console.log("GorillaEditor ready!")
    console.groupEnd()

  @getInstance: (node) ->
    while !!node
        if $(node).hasClass('gorilla-container')
            return GorillaEditor._editor_instances[node.id]
        node = node.parentNode

  viewFile: (render = true) ->
    console.groupCollapsed("Preparing Editor to be viewed")

    me = @

    $(@mainId).addClass('viewing')
    $(@editorId).html(@file.getAnnotatedSequence())
                .addClass('gorilla-editor')
                .find('span')
                  .unbind('mouseenter mouseleave mousemove')
                  .hover((event) -> me.showHoverDialog(event))
                  .mousemove((event) -> me.showHoverDialog(event))

    if render
        @renderNumbers('viewing')
        $(window).resize((event) -> me.renderNumbers('viewing', true))
    console.log("Ready to view")
    console.groupEnd()

  startEditing: () ->
    console.groupCollapsed("Preparing Editor to be edited")
    me = @

    @viewFile(false)
    $(@mainId).removeClass('viewing')
              .addClass('editing')

    @renderNumbers('editing')
    $(@editorId).resize((event) -> me.renderNumbers('editing', true))

    $(@editorId).attr('contenteditable','true')
                .attr('spellcheck','false')

    @bindEditEvents()

    $('#save').click ->
      if saveURL == ""
        notify "No Save URL Specified", "error"
      else
        $.ajax
          type: "POST",
          url: saveURL,
          data:
            extra: extra
            file: me.file.serialize()
          success: ->
            notify "File Saved Successfully", "success"
          error: ->
            notify "Unable to save file", "error"

    @editorContents = $(@editorId).text()
    @editorHtml = $(@editorId).html()
    @previousEditors = []
    @nextEditors = []
    @previousFiles = []
    @nextFiles = []
    console.log("Editor ready!")

    console.groupEnd()

  bindEditEvents: () ->
    me = @
    $(@editorId).find("*").andSelf()
                .unbind('keypress')
                .unbind('keydown')
                .unbind('keyup')
                .unbind('dragenter')
                .unbind('dragleave')
                .unbind('dragover')
                .unbind('drop')
                .unbind('copy cut paste')
                .unbind('input')
                .unbind('mouseup mousemove keydown click focus')

    $(@editorId).find('span')
                .unbind('mouseenter mouseleave mousemove')
                .hover((event) -> me.showHoverDialog(event))
                .mousemove((event) -> me.showHoverDialog(event))

    $(@editorId).bind('input', (event) -> me.textChanged(event))
                .bind('keypress', (event) -> me.keyPressed(event))
                .bind('keydown', (event) -> me.keyDown(event))
                .bind('keyup', (event) -> me.keyUp(event))
                .bind('mouseup mousemove keydown click focus', (event) ->
                    setTimeout((-> me.cursorUpdate(event)), 10))
                .bind('dragenter', (event) -> event.preventDefault())
                .bind('dragleave', (event) -> event.preventDefault())
                .bind('dragover', (event) -> event.preventDefault())
                .bind('drop', (event) -> event.preventDefault())
                .bind('copy', (event) -> me.copy(event))
                .bind('cut', (event) -> me.cut(event))
                .bind('paste', (event) -> me.paste(event))

    Mousetrap.unbind(['ctrl+z', 'command+z', 'ctrl+y', 'command+y'])
    Mousetrap.bindGlobal(['ctrl+z', 'command+z'], (event) -> me.undo())
    Mousetrap.bindGlobal(['ctrl+y', 'command+y'], (event) -> me.redo())

  @cursorPosition: (pos, element) ->
    if element.parentNode.tagName == "SPAN"
        element = element.parentNode
    element = element.previousSibling

    while !!element
        pos += $(element).text().length
        element = element.previousSibling
    return pos

  @getSelectionRange: (sel) ->
    sel = Mouse.getCursorPosition()
    if sel.type == "caret"
      return [sel.start]
    else if sel.type =="range"
      return [sel.start, sel.end]
    return []

  cursorUpdate: (event) ->
    sel = Mouse.getCursorPosition()
    if sel
      if sel.type == "caret"
        $('#positionData').text("#{sel.start} <#{sel.start % 3}>")
      else if sel.type == "range"
        txt = ""
        txt += "Start #{sel.start} &lt;#{sel.start % 3}&gt; "
        txt += "End #{sel.end} &lt;#{sel.end % 3}&gt; "
        length = sel.end - sel.start
        txt += "Length #{length} &lt;#{length % 3}&gt; "
        dispCodons = codons = @file.getCodons(sel.start, sel.end)

        if codons.length > 50
            dispCodons = codons[..25] + "..." + codons[(codons.length - 25)..]
        txt += "<br>" + dispCodons

        $('#positionData').html(txt)

  showHoverDialog: (event) ->
    if event.type == "mouseleave"
      $('#hover-box').remove()
      return
    if event.type == "mouseenter"
      $('#hover-box').remove()
      console.log "enter"
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
    $('#get-chars-wide-gorilla').addClass("gorilla-container #{type}")
    $('#get-chars-wide-gorilla .editor').addClass("gorilla-editor")

    $('#get-chars-wide-gorilla .numbers').html('1<br>2')
    node = $('#get-chars-wide-gorilla .editor')
    txt = 'aaaaaaa'
    node.text(txt)
    hei = node.height()
    while hei >= node.height() and txt.length < 2000
        txt += 'aaaaaaa'
        node.text(txt)
    while hei < node.height() and txt.length > 0
        txt = txt[1..]
        node.text(txt)
    $('#get-chars-wide-gorilla').remove()
    return txt.length

  renderNumbers: (type = 'editing', resize = false) ->
    $(@numbersId).html('1')
    if not @chars? or resize
        @chars = @getCharsWide(type)
    lines = $(@editorId).get(0).clientHeight / 16
    text = ''
    loc = 1
    for line in [0...lines]
        text += loc + '<br>'
        loc += @chars
    $(@numbersId).html(text)

  trackChanges: ->
    Autosave.request(this)
    @previousFiles.push($.extend(true, {}, @file))

  completeEdit: (rebind = false) ->
    @bindEditEvents()
    @renderNumbers()
    @file.updateSequence($(@editorId).text())
    if @debugEditor?
      @debugEditor.file = new G.GenBank(@file.serialize())
      @debugEditor.viewFile()

  deleteAtCursor: (key = "<backspace>") ->
    sel = window.getSelection()
    console.log sel

    @trackChanges()
    if sel.isCollapsed

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
        if element.tagName != "SPAN"
          if not $(element.parentNode).hasClass('editor')
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
    else
      indicies = GorillaEditor.getSelectionRange(window.getSelection())
      if indicies.length == 2
        @deleteSelection(indicies)
        $(@editorId).html(@file.getAnnotatedSequence())
        Mouse.setCaretIndex(@editorId, indicies[0])
      else
        console.error "How Dare You"
    @completeEdit()

  deleteSelection: (indicies) ->
    removalAmount = 0
    if indicies.length == 2
      [sIndex, eIndex] = indicies
      @file.replaceSequence("", sIndex, eIndex)
      removalAmount = eIndex - sIndex
      eIndex--
    else
      return

    handledRange = {}

    @iterateOverFileRange(sIndex, sIndex, (feature, range, file) ->
      distanceInRange = sIndex - range.start - 1
      if sIndex != range.start
        if feature.location.ranges.length > 1
          hash = feature.id.toString() + ',' + range.id.toString()
          handledRange[hash] = true
          if eIndex > range.end
            range.end = sIndex - 1
          else
            range.end -= 1 + eIndex - sIndex
        else
          file.splitFeatureAtInPlace(feature.id, range.id, distanceInRange))

    @iterateOverFileRange(eIndex, eIndex, (feature, range, file) ->
      distanceInRange = eIndex - range.start
      if eIndex != range.end
        hash = feature.id.toString() + ',' + range.id.toString()
        if feature.location.ranges.length > 1 and not handledRange[hash]
          handledRange[hash] = true
          if sIndex < range.start
            range.start = sIndex
            range.end = sIndex - 1 + (range.end - eIndex)
        else
          file.splitFeatureAtInPlace(feature.id, range.id, distanceInRange))

    seenFeatures = {}
    allFeats = @file.getTableOfFeatures()
    featRangePairs = []
    for i in [sIndex .. eIndex]
      if allFeats[i]
        for pair in allFeats[i]
          hash = pair.feature.id.toString() + ',' + pair.range.id.toString()
          if not seenFeatures[hash]
            seenFeatures[hash] = true
            if not handledRange[hash]
              featRangePairs.push([pair.feature, pair.range])
    @file.removeRanges(featRangePairs)

    @iterateOverFileRange(sIndex, -1 , (feature, range, file) ->
      hash = feature.id.toString() + ',' + range.id.toString()
      if not handledRange[hash]
        file.advanceFeature(feature.id, range.id, -1 * removalAmount))

  #Iterates over a specified range in the file
  #if end is -1 then the range goes to the end of the file           
  iterateOverFileRange: (start, end, funct) ->
    seenFeatures = {}
    allFeats = @file.getTableOfFeatures()
    if end == -1
       end = allFeats.length - 1
    if start > end
      return
    for i in [start .. end]
      if allFeats[i]
        for pair in allFeats[i]
          hash = pair.feature.id.toString() + ',' + pair.range.id.toString()
          if not seenFeatures[hash]
            seenFeatures[hash] = true
            funct(pair.feature, pair.range, @file)

  paste: (event, isRevComp = false) ->
    console.groupCollapsed("Handling Paste")
    event.preventDefault()
    sel = window.getSelection()
    indicies = GorillaEditor.getSelectionRange(sel)
    @trackChanges()

    insert = indicies[0]

    #Determine which clipboard to use
    if event.originalEvent != undefined and event.originalEvent.clipboardData != undefined
      cb = event.originalEvent.clipboardData.getData('text/plain')
    else
      cb = @copiedInfo.text
    console.log("Clipboard contains: ",cb)
    console.log("Local Clipboard contains: ",@copiedInfo)
    if @copiedInfo == undefined or @copiedInfo.text != cb
      #screen input
      l = cb.length
      filteredText = ""
      for i in [0 ... l]
        invalidChar = false
        if "agtcnACTGN".indexOf(cb[i]) == -1
          invalidChar = true
          #need to add option here to let them remove invalid chars or to replace them with N or to cancel the paste
          replaceWithN = false #default for the moment is to strip out invalid chars
          if replaceWithN
            filteredText += "N"
        else
          filteredText += cb[i]
      console.log("Text is good to go!")
      textToPaste = filteredText
      useFeats = false
    else
      textToPaste = @copiedInfo.text
      useFeats = true

    #Add copied features in sorted order to the features list, modifying the ranges of each
    if useFeats
      end = textToPaste.length - 1
      if isRevComp
        for f in @copiedInfo.features
          f.location.strand ^= 1
          for r in f.location.ranges
            rangeLen = r.end - r.start
            r.start = end - rangeLen - r.start
            r.end = end - r.start

      featList = []
      for f in @copiedInfo.features
        featList.push(f)
      featList.sort (a,b) -> a.id - b.id

      newFeats = []
      i = @file.getFeatures().length
      for f in featList
        feat = $.extend(true, {}, f)
        feat.id = i++
        j = 0
        for r in feat.location.ranges
          r.id = j++
          r.start += insert
          r.end += insert
        newFeats.push(feat)


    joined = true

    allFeats = @file.getTableOfFeatures()
    #split feats at insert
    if insert != 0 and insert != @file.getGeneSequence().length
      if allFeats[insert]
        for p in allFeats[insert]
          f = p.feature
          r = p.range
          if r.start < insert
            if joined
              newRange =
                start:insert
                end:r.end
                id:f.location.ranges.length
              r.end = insert - 1
              f.location.ranges.push(newRange)

    #shift all feats after insert
    @iterateOverFileRange(insert, -1 , (feature, range, file) ->
      file.advanceFeature(feature.id, range.id, textToPaste.length))

    #update info and complete the edit
    @file.replaceSequence(textToPaste, insert, insert)
    if useFeats
      @file.addFeatures(newFeats)
    $(@editorId).html(@file.getAnnotatedSequence())
    sel = Mouse.getCursorPosition()
    Mouse.setCaretIndex(@editorId, indicies[0] + textToPaste.length)
    @completeEdit()
    console.groupEnd()

  cut: (event) ->
    console.groupCollapsed("Handling Cut")
    @copy(event)
    sel = window.getSelection()
    indicies = GorillaEditor.getSelectionRange(sel)
    if indicies.length == 2
      @trackChanges()
      @deleteSelection(indicies)
      $(@editorId).html(@file.getAnnotatedSequence())
      sel.collapse(true)
      Mouse.setCaretIndex(@editorId, indicies[0])
      @completeEdit()
    console.groupEnd()

  copy: (event) ->
    console.groupCollapsed("Handling Copy")
    event.preventDefault()
    indicies = GorillaEditor.getSelectionRange(window.getSelection())
    @fileCopy = $.extend(true, {}, @file)
    if indicies.length < 2
      return

    if indicies.length == 2
      [sIndex, eIndex] = indicies
      eIndex--
    else
      return

    allFeats = @fileCopy.getTableOfFeatures()
    if allFeats[sIndex]
      for pair in allFeats[sIndex]
        feature = pair.feature
        range = pair.range
        distanceInRange = sIndex - range.start - 1
        if sIndex != range.start and feature.location.ranges.length == 1
          @fileCopy.splitFeatureAtInPlace(feature.id, range.id, distanceInRange)
            
    allFeats = @fileCopy.getTableOfFeatures()
    if allFeats[eIndex]
        for pair in allFeats[eIndex]
          feature = pair.feature
          range = pair.range
          distanceInRange = eIndex - range.start
          if eIndex != range.end and feature.location.ranges.length == 1
            @fileCopy.splitFeatureAtInPlace(feature.id, range.id, distanceInRange)

    seenFeatures = {}
    allFeats = @fileCopy.getTableOfFeatures()
    for i in [sIndex .. eIndex]
      if allFeats[i]
        for pair in allFeats[i] #gives us a list of feat_id, range_id
          feature = pair.feature
          range = pair.range
          if not seenFeatures[feature] and feature.location.ranges.length > 1
            seenFeatures[feature] = true
            @fileCopy.splitJoinedFeature(feature, sIndex, eIndex)

    seenFeatures = {}
    allFeats = @fileCopy.getTableOfFeatures()
    featRangePairs = []
    for i in [sIndex .. eIndex]
      if allFeats[i]
        for pair in allFeats[i]
          hash = pair.feature.id.toString() + ',' + pair.range.id.toString()
          if not seenFeatures[hash]
            seenFeatures[hash] = true
            featRangePairs.push([pair.feature, pair.range])
    
    copiedFeatsHash = {}
    copiedFeats = []
    for [f,r] in featRangePairs
      fId = f.id.toString()
      if copiedFeatsHash[fId] == undefined
        newRanges = []
        newLoc =
          ranges:newRanges
          strand:f.location.strand
        newFeat =
          location:newLoc
          id:f.id
          currentFeature:f.currentFeature
          parameters:f.parameters
        copiedFeatsHash[fId] = newFeat
        copiedFeats.push(newFeat)
      feat = copiedFeatsHash[fId]
      newRange =
        start:r.start - sIndex
        end:r.end - sIndex
        id:r.id
      feat.location.ranges.push(newRange)
    data = @file.getGeneSequence().substring(sIndex, eIndex + 1)
    if event.originalEvent != undefined and event.originalEvent.clipboardData != undefined
      event.originalEvent.clipboardData.setData('text/plain',data)
    @copiedInfo =
      text:data
      features:copiedFeats
    console.groupEnd()

  keyDown: (event) ->
    console.log("Key code: ", event.keyCode)
    if event.keyCode == 8
      console.groupCollapsed("Handling Backspace")
      event.preventDefault()
      event.stopPropagation()
      @deleteAtCursor('<backspace>')
    else if event.keyCode == 46
      console.groupCollapsed("Handling Delete")
      event.preventDefault()
      event.stopPropagation()
      @deleteAtCursor('<delete>')
    else
      return
    console.groupEnd()

  keyUp: (event) ->

  keyPressed: (event) ->
    event.preventDefault()

    code = if event.keyCode then event.keyCode else event.which
    char = String.fromCharCode(code)
    console.groupCollapsed("Handling Key: ", char)
    tracked = false

    if "agtcnACTGN".indexOf(char) != -1
      console.log("ooh, exciting!")

      s = Mouse.getCursorPosition()
      if s.type == "range"
        tracked = true
        @trackChanges()
        @deleteSelection([s.start,s.end])
        $(@editorId).html(@file.getAnnotatedSequence())
        Mouse.setCaretIndex(@editorId, s.start)

      sel = window.getSelection()

      if sel.isCollapsed
        if not tracked
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
            newGuy.id = "#{@file.id}-#{newid}"
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
