# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#

class GenBank
  constructor: (@text) ->
    @textLines = @text.split("\n")
    @data = {}
    sectionName = ""
    contents = ""
    for line in @textLines
      if line[0] != " "
        if sectionName != ""
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

  @annotate: (sequence, start, end, color, name) ->
    console?.log "Searching for: #{name}"
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
    beg + "<span style='background-color:#{color}' >" + mid + "</span>" + end

  getAnnotatedSequence: () ->
    seq = @getGeneSequence()
    features = @getFeatures()
    for feature in features
      color = feature.parameters["/ApEinfo_fwdcolor"]
      name = feature.parameters["/label"]
      l = feature.location
      isComplement = l.match(/complement\((.*)\)/)
      if isComplement
        l = isComplement[1]
        color = feature.parameters['/ApEinfo_revcolor']
      isComplement = !!isComplement

      isJoin = l.match(/join\((.*)\)/)
      if isJoin
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
     seq


  getGeneSequence: () ->
    if @data.raw_genes?
      return @data.raw_genes
    retval = ""
    for line in @data.ORIGIN.split('\n')
      retval += line.split(/[ ]*[0-9]* /)[1..].join("")
    @data.raw_genes = retval

  getFeatures: () ->
    if @data.features?
      return @data.features
    retval = []
    currentFeature = ""
    components = ""
    parts = {}
    for line in @data.FEATURES.split("\n")[1..]
      if line.trim()[0] != "/"
        if currentFeature != ""
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
        s = line.trim().split("=")
        parts[s[0]] = s[1][1..-2]
    if parts != {}
      retval.push
        currentFeature: currentFeature
        location: components
        parameters: parts

    @data.features = retval

window.GorillaEditor = class
  constructor: (@editorId, @initialDocument) ->
    @file = new GenBank(@initialDocument)

  startEditing: () ->
    $(@editorId).css('width','100%')
                .css('word-wrap','break-word')
                .css('font-family','monospace')
                .attr('contenteditable','true')
                .html(@file.getAnnotatedSequence())
