# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

#= require logging

if !String.prototype.format
  String.prototype.format = () ->
    args = arguments
    return this.replace /{(\d+)}/g, (match, number) ->
        return if (typeof args[number] != 'undefined') then args[number] else match

String.prototype.padBy = (length) ->
  pad = length - this.length
  retval = this
  while pad > 0
    retval = retval.concat(" ")
    pad -= 1
  retval

logger = new Log(lc.ALL,ll.LOG)

class window.GenBank
  constructor: (@text) ->
    logger.enter()
    @newline = "\n"
    if @text.indexOf("\r\n") != -1
      @newline = "\r\n"
    else if @text.indexOf("\r") != -1
      @newline = "\r"
    @textLines = @text.split(@newline)
    @data = {}
    sectionName = ""
    contents = ""
    logger.d("Looking at the lines")
    for line in @textLines
      logger.enter()
      if line[0] != " "
        if sectionName != ""
          logger.d("Found section #{sectionName}")
          @data[sectionName] = contents
          contents = ""
        lineParts = line.split(/[ ]+/)
        sectionName = lineParts[0]
        if lineParts.length > 1
          if sectionName != "LOCUS"
            contents = lineParts[1..].join(" ")
          else
            contents =
              name: lineParts[1]
              length: lineParts[2] + " " + lineParts[3]
              type: lineParts[4..5].join(" ")
              division: lineParts[6]
              date: lineParts[7]


      else if sectionName != ""
        if contents == ""
          contents = line
        else
          contents += @newline + line
      logger.exit()
    logger.exit()

  @annotate: (sequence, start, end, color, name, spanId, featureId) ->
    logger.enter()
    logger.d("Adding annotation to sequence: (#{start}..#{end})")
    if typeof(start) != "number"
      start = parseInt(start) - 1
    if typeof(end) != "number"
      end = parseInt(end) - 1
    count = true
    current = 0
    startix = 0
    endix = 0
    for x in [0..sequence.length]
      if sequence[x] == "<"
        count = false
      if current == start
        startix = x
      if current == end
        endix = x
        break
      if count
        current += 1
      if sequence[x] == ">"
        count = true
    beg = sequence[...startix]
    end = sequence[endix+1..]
    mid = sequence[startix..endix]
    logger.exit()
    beg + "<span id='#{name}-#{featureId}-#{spanId}' class='#{name}-#{featureId}' style='background-color:#{color}' >" + mid + "</span>" + end

  @annotateFeature: (seq, feature) ->
    color = feature.parameters["/ApEinfo_fwdcolor"]
    if feature.location.strand == 1
      color = feature.parameters["/ApEinfo_revcolor"]
    name = feature.parameters["/label"]
    for span in feature.location.ranges
      seq = GenBank.annotate(seq, span.start, span.end, color, name, span.id, feature.id)
    seq

  @findRangeById: (ranges, spanId) ->
    if ranges.uid == spanId
      return ranges
    for range in ranges
      r = GenBank.findRangeById(range, spanId)
      return r if !!r
    return null
    
  splitFeatureAt: (featId, rangeId, newLength) ->
    f = @getFeatures()[featId]
    rangeIx = GenBank.rangeIndex(f, rangeId)
    newFeat = $.extend(true, {}, f)
    newFeat.id = @getFeatures().length
    newFeat.location.ranges[rangeIx].start += newLength + 1
    newFeat.location.ranges = newFeat.location.ranges[rangeIx..]
    @getFeatures().push(newFeat)
    r = f.location.ranges[rangeIx]
    r.end = r.start + newLength
    f.location.ranges = f.location.ranges[..rangeIx]

    new: newFeat
    old: f

  advanceFeature: (featId, rangeId, amount) ->
    logger.d("Advancing #{featId}-#{rangeId}")
    f = @getFeatures()[featId]
    r = GenBank.getRange(f.location, rangeId)
    r.start += amount
    r.end += amount

  @rangeIndex: (feature, id) ->
    i = 0
    for range in feature.location.ranges
      if range.id == id
        return i
      i += 1

  @getRange: (location, id) ->
    for range in location.ranges
      if range.id == id
        return range
    return null

  getAnnotatedSequence: () ->
    logger.enter()
    logger.d("Parsing data from file")
    seq = @getGeneSequence()
    features = @getFeatures()
    logger.d("Looking through the features")
    logger.enter()
    for feature in features
      logger.l feature
      seq = GenBank.annotateFeature(seq, feature)
    logger.exit()
    seq

  getGeneSequence: () ->
    logger.enter()
    logger.d("Getting gene sequence")
    if @data.raw_genes?
      logger.d("We already calculated the gene sequence!")
      logger.exit()
      return @data.raw_genes
    retval = ""
    for line in @data.ORIGIN.split(@newline)
      retval += line.split(/[ ]*[0-9]* /)[1..].join("")
    logger.d("Gene sequence found!")
    logger.exit()
    @data.raw_genes = retval

  updateSequence: (seq) ->
    @data.raw_genes = seq

  @serializeLocation: (loc) ->
    retval = ""
    for range in loc.ranges
      retval += "," if retval != ""
      retval += "#{range.start+1}..#{range.end+1}"
    if loc.ranges.length > 1
      retval = "join(#{retval})"
    if loc.strand == 1
      retval = "complement(#{retval})"
    retval

  serialize: () ->
    file = "LOCUS".padBy(12) + @data.LOCUS.name.padBy(13) + @data.LOCUS.length.padBy(11) + @data.LOCUS.type.padBy(16) + @data.LOCUS.division + " " + @data.LOCUS.date + @newline
    # file = "LOCUS".padBy(12) + @data.LOCUS + @newline
    for own section,contents of @data
      if ["LOCUS", "FEATURES", "ORIGIN", "//", "raw_genes", "features"].indexOf(section) == -1
        file += section.padBy(12) + contents + @newline
    file += @serializeFeatures()
    file += @serializeGenes()

  serializeFeatures: () ->
    features = "FEATURES             Location/Qualifiers" + @newline
    for feat in @getFeatures()
      features += "     " + feat.currentFeature.padBy(16) + GenBank.serializeLocation(feat.location) + @newline
      for own key, value of feat.parameters
        features += "                     " + "#{key}=\"#{value}\" " + @newline
    features

  serializeGenes: () ->
    count = 0
    increment = 60
    group_size = 10
    offset = 9
    serialized = "ORIGIN" + @newline
    genes = @getGeneSequence()
    num_iter = Math.ceil(genes.length / (count+increment))
    for i in [0...num_iter] by 1
        leading_num = i*increment + 1
        num_digits = Math.floor(Math.log(leading_num) / Math.LN10) + 1
        for spaces in [0...offset - num_digits] by 1
            serialized += " "
        serialized += leading_num.toString()
        serialized += " "

        for j in [0...increment/group_size] by 1
            serialized += genes.substring(count, count + 10)
            serialized += " "
            count += 10
        serialized += @newline
    return serialized + "// " + @newline

  @parseLocationData: (data) ->
    id = 0
    logger.enter()
    logger.d("Parsing Location Data")
    isComplement = data.match(/^complement\((.*)\)$/)
    strand = 0
    ranges = []
    if !!isComplement
      strand = 1
      data = isComplement[1]
    isJoin = data.match(/^join\((.*)\)$/)
    if !!isJoin
      for r in isJoin[1].split(',')
        parts = ((parseInt(a) - 1) for a in r.split('..'))
        ranges.push
          start: parts[0]
          end: parts[1]
          id: id
        id += 1
    else
      parts = ((parseInt(a) - 1) for a in data.split('..'))
      ranges.push
        start: parts[0]
        end: parts[1]
        id: id

    logger.exit()

    retval =
      strand: strand
      ranges: ranges

  getFeatures: () ->
    logger.enter()
    logger.d("Getting features")
    if @data.features?
      logger.d("We already parsed the features!")
      logger.exit()
      return @data.features
    retval = []
    currentFeature = ""
    components = ""
    parts = {}

    id = 0

    logger.d("Looking at each feature")
    logger.enter()
    for line in @data.FEATURES.split(@newline)[1..]
      if line.trim()[0] != "/"
        logger.d("This is the start of a new feature")
        if currentFeature != ""
          logger.d("Storing old feature")
          data =
            currentFeature: currentFeature
            location: components
            parameters: parts
            id: id
          id += 1
          retval.push(data)
          parts = {}
        p = line.trim().split(/[ ]+/)
        currentFeature = p[0]
        components = p[1..].join(" ")
        components = GenBank.parseLocationData(components)
      else
        logger.d("Adding new component to the feature")
        s = line.trim().split("=")
        parts[s[0]] = s[1][1..-2]
    logger.exit()
    if parts != {}
      retval.push
        currentFeature: currentFeature
        location: components
        parameters: parts
        id: id
    logger.d("Here's your features sir!")
    logger.exit()
    @data.features = retval

class window.GorillaEditor
  constructor: (@editorId, @initialDocument = '', @debugEditor = null) ->
    logger.d("Initializing GorillaEditor...")
    if @initialDocument != ''
      @file = new GenBank(@initialDocument)
      if @debugEditor != null
        @debugEditor.file = new GenBank(@initialDocument)
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
                .attr('tabindex', '0')
                .html(@file.getAnnotatedSequence())
    $(@editorId).find("*").andSelf().unbind('keypress').unbind('keydown').unbind('keyup')
    $(@editorId).bind('input', (event) -> me.textChanged(event))
                .keypress((event) -> me.keyPressed(event))
                .keydown((event) -> me.keyDown(event))
                .keyup((event) -> me.keyDown(event))
    @editorContents = $(@editorId).text()
    @editorHtml = $(@editorId).html()
    @previousEditors = []
    @nextEditors = []
    logger.d("Editor ready!")

  undo: (me, event) ->
    me.nextEditors.push([me.editorHtml, $.extend(true, {}, me.file)])
    parts = me.previousEditors.pop()
    me.editorHtml = parts[0]
    me.editor = parts[1]

    $(me.editorId).html(me.editorHtml)
    me.editorContents = $(me.editorId).text()

  deleteAtCursor: () ->
    sel = window.getSelection()

    if sel.type == "Caret"
      loc = sel.getRangeAt(0)

      caretPosition = loc.startOffset

      element = loc.startContainer
      pe = element.parentNode

      element.deleteData(caretPosition-1, 1)
      
      node = element
      while !!node
        if node.tagName == "SPAN"
          spl = node.id.split('-')
          featureId = parseInt(spl[1])
          rangeId = parseInt(spl[2])
          @file.advanceFeature(featureId, rangeId, -1)
        node = node.nextSibling


    else
      logger.wtf "How Dare You"

  keyDown: (event) ->
    if event.keyCode == 8
      logger.l "Backspace"
      event.preventDefault()
      @deleteAtCursor()

  keyUp: (event) ->

  keyPressed: (event) ->
    event.preventDefault()

    logger.enter()

    char = String.fromCharCode(event.keyCode).toLowerCase()
    if "agtc".indexOf(char) != -1
      logger.d "ooh, exciting!"
      sel = window.getSelection()

      if sel.type == "Caret"
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
            newGuy.id = "#{feat.new.parameters['/label']}-#{feat.new.id}-#{spanId}"
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

        @previousEditors.push([@editorHtml, $.extend(true, {}, @file)])
        @editorHtml = $(@editorId).html()
        if @debugEditor != null
          @file.updateSequence($(@editorId).text())
          @debugEditor.file = new GenBank(@file.serialize())
          @debugEditor.startEditing()

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
    return
    @previousContents = @editorContents
    @editorContents = $(@editorId).text()

    sel = window.getSelection()

    loc = sel.getRangeAt(0)

    caretPosition = loc.startOffset

    element = loc.startContainer
    pe = element.parentNode

    if @previousContents.length > @editorContents.length
      difference = @editorContents.length - @previousContents.length
      node = pe
      if node.tagName == "SPAN"
        spl = node.id.split('-')
        fid = parseInt(spl[1])
        rid = parseInt(spl[2])
        @file.getFeatures()[fid].end += difference
      while !!node
          if node.tagName == "SPAN"
            logger.l("spanning #{node.id}")
            spl = node.id.split('-')
            featureId = parseInt(spl[1])
            rangeId = parseInt(spl[2])
            @file.advanceFeature(featureId, rangeId, difference)
          node = node.nextSibling
    else
      return if caretPosition == 0

      if "acgt".indexOf($(element).text()[caretPosition-1]) == -1
        t = element.textContent
        element.textContent = t[0...caretPosition-1] + t[caretPosition..]
        caretPosition -= 1
      else if pe.tagName == "SPAN"
        idSplit = pe.id.split('-')
        featureId = parseInt(idSplit[1])
        spanId = parseInt(idSplit[2])

        end = element.splitText(caretPosition)
        char = element.splitText(caretPosition-1)
        start = element

        newFeature = @file.splitFeatureAt(featureId, spanId, caretPosition-1)

        node = pe
        while !!node
          if node.tagName == "SPAN"
            spl = node.id.split('-')
            logger.d(spl)
            featureId = parseInt(spl[1])
            rangeId = parseInt(spl[2])
            @file.advanceFeature(featureId, rangeId, 1)
          node = node.nextSibling

        pe.removeChild(char)
        pe.removeChild(end)
        pe.parentNode.insertBefore(char, pe.nextSibling)

        logger.l newFeature

        newGuy = document.createElement("SPAN")
        newGuy.id = "#{newFeature.parameters['/label']}-#{newFeature.id}-#{newFeature.location.uid}"
        newGuy.className = "#{newFeature.parameters['/label']}-#{newFeature.id}"
        newGuy.setAttribute("style", pe.getAttribute('style'))
        newGuy.appendChild(end)
        pe.parentNode.insertBefore(newGuy, char.nextSibling)
        element = newGuy
        caretPosition = 1
        ins = true
        

      sel.removeAllRanges()

      elem = document.getElementById($(pe).attr('id'))
      l = document.createRange()
      if ins
        l.setStartBefore(element)
      else
        l.setStart(element, caretPosition)
      l.collapse(true)

      sel.addRange l

      if @editorHtml != $(@editorId).html()
        @previousEditors.push([@editorHtml, $.extend(true, {}, @file)])
        @editorHtml = $(@editorId).html()
        if @debugEditor != null
          @file.updateSequence($(@editorId).text())
          @debugEditor.file = new GenBank(@file.serialize())
          @debugEditor.startEditing()

      # $('#gb').text(@file.serialize())
