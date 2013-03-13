# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

#= require logging

logger = new Log(lc.ALL,ll.LOG)

class GenBank
  constructor: (@text) ->
    logger.enter()
    @textLines = @text.split("\n")
    @data = {}
    sectionName = ""
    contents = ""
    logger.d("Looking at the lines")
    logger.enter()
    for line in @textLines
      if line[0] != " "
        if sectionName != ""
          logger.d("Found section #{sectionName}")
          @data[sectionName] = contents
          contents = ""
        lineParts = line.split(/[ ]+/)
        sectionName = lineParts[0]
        if lineParts.length > 1
          contents = lineParts[1..].join(" ")
      else if sectionName != ""
        if contents == ""
          contents = line
        else
          contents += "\n" + line
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
    beg + "<span id='#{name}-#{spanId}' class='#{name}-#{featureId}' style='background-color:#{color}' >" + mid + "</span>" + end

  @annotateFeature: (seq, feature, loc = feature.location, color = "") ->
    color or= feature.parameters["/ApEinfo_fwdcolor"]
    if loc.isComplement
      color = feature.parameters["/ApEinfo_revcolor"]
    name = feature.parameters["/label"]
    for span in loc.ranges
      if span.isComplement?
        feature.uid += 10000
        seq = GenBank.annotateFeature(seq, feature, span, color)
      else
        start = span[0]
        end = span[1]
        seq = GenBank.annotate(seq, start, end, color, name, feature.uid, feature.id)
    seq

  @findRangeById: (ranges, spanId) ->
    if ranges.uid == spanId
      return ranges
    for range in ranges
      r = GenBank.findRangeById(range, spanId)
      return r if !!r
    return null
    
  updateFeatureLength: (featId, spanId, newLength) ->
    f = @getFeatures()[featId]
    logger.d GenBank.findRangeById(f.location, spanId)


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
    for line in @data.ORIGIN.split('\n')
      retval += line.split(/[ ]*[0-9]* /)[1..].join("")
    logger.d("Gene sequence found!")
    logger.exit()
    @data.raw_genes = retval

  @parseLocationData: (data) ->
    logger.enter()
    logger.d("Parsing Location Data")
    isComplement = data.match(/^complement\((.*)\)$/)
    comp = false
    ranges = []
    if !!isComplement
      comp = true
      data = isComplement[1]
    isJoin = data.match(/^join\((.*)\)$/)
    if !!isJoin
      for r in isJoin[1].split(',')
        ranges.push(GenBank.parseLocationData(r))
    else
      ranges.push((parseInt(a) - 1) for a in data.split('..'))
    logger.exit()

    retval =
      isComplement: comp
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
    for line in @data.FEATURES.split("\n")[1..]
      if line.trim()[0] != "/"
        logger.d("This is the start of a new feature")
        if currentFeature != ""
          logger.d("Storing old feature")
          data =
            currentFeature: currentFeature
            location: components
            parameters: parts
            id: id
            uid: id
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
        uid: id
    logger.d("Here's your features sir!")
    logger.exit()
    @data.features = retval

class window.GorillaEditor
  constructor: (@editorId, @initialDocument) ->
    logger.d("Initializing GorillaEditor...")
    @file = new GenBank(@initialDocument)
    logger.d("GorillaEditor ready!")

  startEditing: () ->
    logger.d("Preparing Editor...")
    me = @
    $(@editorId).css('width','100%')
                .css('word-wrap','break-word')
                .css('font-family','monospace')
                .attr('contenteditable','true')
                .attr('spellcheck','false')
                .html(@file.getAnnotatedSequence())
                .bind('input', (target) -> me.textChanged(me, target))
    logger.d("Editor ready!")
  
  textChanged: (me, target) ->
    sel = window.getSelection()

    loc = sel.getRangeAt(0)

    caretPosition = loc.startOffset

    return if caretPosition == 0

    element = loc.startContainer
    pe = element.parentNode

    if "acgt".indexOf($(element).text()[caretPosition-1]) == -1
      t = element.textContent
      element.textContent = t[0...caretPosition-1] + t[caretPosition..]
      caretPosition -= 1
    else if pe.tagName == "SPAN"
      featureId = parseInt(pe.className.split('-')[1])
      spanId = parseInt(pe.id.split('-')[1])
      end = element.splitText(caretPosition)
      char = element.splitText(caretPosition-1)
      start = element
      me.file.updateFeatureLength featureId, caretPosition
      pe.removeChild(char)
      pe.removeChild(end)
      pe.parentNode.insertBefore(char, pe.nextSibling)
      newGuy = document.createElement("SPAN")
      newGuy.setAttribute("id", pe.getAttribute('id') + "-")
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
