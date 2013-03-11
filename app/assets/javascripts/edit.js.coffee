# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

#= require logging

logger = new Log(lc.ALL,ll.DEBUG)

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

  @annotate: (sequence, start, end, color, name) ->
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
    beg + "<span id='#{name}' style='background-color:#{color}' >" + mid + "</span>" + end

  getAnnotatedSequence: () ->
    logger.enter()
    logger.d("Parsing data from file")
    seq = @getGeneSequence()
    features = @getFeatures()
    logger.d("Looking through the features")
    logger.enter()
    for feature in features
      color = feature.parameters["/ApEinfo_fwdcolor"]
      name = feature.parameters["/label"]
      logger.d("Feature: '#{name}' has been found")
      l = feature.location
      isComplement = l.match(/complement\((.*)\)/)
      if isComplement
        logger.d("This refers to the complement strand")
        l = isComplement[1]
        color = feature.parameters['/ApEinfo_revcolor']
      isComplement = !!isComplement

      isJoin = l.match(/join\((.*)\)/)
      if isJoin
        logger.d("This is a joint of multiple sequences")
        l = isJoin[1]
      isJoin = !!isJoin
      if isJoin
        for group in l.split(",")
          m = group.match(/([0-9]+)\.\.([0-9]+)/)
          if m
            start = m[1]
            end = m[2]
            seq = GenBank.annotate(seq, start, end, color, name)
      else
        matches = l.match(/([0-9]+)\.\.([0-9]+)/)
        if matches
          start = matches[1]
          end = matches[2]
          seq = GenBank.annotate(seq, start, end, color, name)
     logger.exit()
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
          retval.push(data)
          parts = {}
        p = line.trim().split(/[ ]+/)
        currentFeature = p[0]
        components = p[1..].join(" ")
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
    logger.d("Here's your features sir!")
    logger.exit()
    @data.features = retval

window.GorillaEditor = class
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
      end = element.splitText(caretPosition)
      char = element.splitText(caretPosition-1)
      start = element
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

    return

    position = window.getSelection().getRangeAt(0)
    caretPosition = position.startOffset
    console.log caretPosition
    if caretPosition == 0
      return
    element = position.startContainer.parentElement
    console.log element
    console.log $(element).text()
    if $(element) == $(@editorId)
      console.log "hi"
    beforeText = $(element).text()[0...caretPosition-1]
    newChar = $(element).text()[caretPosition-1]
    afterText = $(element).text()[caretPosition..]
    console.log "#{beforeText} #{newChar} #{afterText}"
    $(element).text(beforeText)
    $(element).after(newChar)
              .after("<span style='background-color:#{$(element).css('background-color')}' >#{afterText}</span>")
    #$(element).text($(element).text()[0...-1])
