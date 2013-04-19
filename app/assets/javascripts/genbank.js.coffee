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


window.G or= {}

window.G.GenBank = class GenBank
  @codons:
    uuu: 'F', uuc: 'F'
    uua: 'L', uug: 'L', cuu: 'L', cuc: 'L', cua: 'L', cug: 'L'
    auu: 'I', auc: 'I', aua: 'I'
    aug: 'M'
    guu: 'V', guc: 'V', gua: 'V', gug: 'V'
    ucu: 'S', ucc: 'S', uca: 'S', ucg: 'S'
    ccu: 'P', ccc: 'P', cca: 'P', ccg: 'P'
    acu: 'T', acc: 'T', aca: 'T', acg: 'T'
    gcu: 'A', gcc: 'A', gca: 'A', gcg: 'A'
    uau: 'Y', uac: 'Y'
    uaa: '*', uag: '*'
    cau: 'H', cac: 'H'
    caa: 'Q', cag: 'Q'
    aau: 'N', aac: 'N'
    aaa: 'K', aag: 'K'
    gau: 'D', gac: 'D'
    gaa: 'E', gag: 'E'
    ugu: 'C', ugc: 'C'
    uga: '*'
    ugg: 'W'
    cgu: 'R', cgc: 'R', cga: 'R', cgg: 'R'
    agu: 'S', agc: 'S'
    aga: 'R', agg: 'R'
    ggu: 'G', ggc: 'G', gga: 'G', ggg: 'G'

  constructor: (@text, @id = "default") ->
    console.groupCollapsed("GenBank Constructor #{@id}")
    @newline = "\n"
    if @text.indexOf("\r\n") != -1
      @newline = "\r\n"
    else if @text.indexOf("\r") != -1
      @newline = "\r"
    @textLines = @text.split(@newline)
    @data = {}
    sectionName = ""
    contents = ""
    console.groupCollapsed("Looking at the lines")
    for line in @textLines
      if line[0] != " "
        if sectionName != ""
          console.debug("Found section #{sectionName}")
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
              length: lineParts[2]
              type: lineParts[4..5].join(" ")
              division: lineParts[6]
              date: lineParts[7]

      else if sectionName != ""
        if contents == ""
          contents = line
        else
          contents += @newline + line
    console.groupEnd()
    console.groupEnd()

  annotateOld: (sequence, start, end, color, name, spanId, featureId) ->
    console.groupCollapsed("Adding annotation #{featureId}-#{spanId} to sequence: (#{start}..#{end})")
    if typeof(start) != "number"
      start = parseInt(start) - 1
    if typeof(end) != "number"
      end = parseInt(end) - 1
    count = true
    current = 0
    startix = -1
    endix = -1
    for x in [0..sequence.length]
      if sequence[x] == "<"
        count = false
      if current == start
        startix = x
      if current == end
        endix = x
      if count
        current += 1
      if sequence[x] == ">"
        count = true
    if startix == -1 or endix == -1
      console.error("End index or start index not found...", startix, endix)
      if current == start
        startix = x
      if current == end
        endix = x
    console.log(startix, endix)
    beg = sequence[...startix]
    end = sequence[endix+1..]
    mid = sequence[startix..endix]
    console.groupEnd()
    beg + "<span id='#{name}-#{featureId}-#{spanId}-#{@id}' class='#{name}-#{featureId}' style='background-color:#{color}'>" + mid + "</span>" + end

  getCodons: (start, end) ->
    txt = @getGeneSequence()[start...end].toLowerCase()
    codons = ""
    while txt.length >= 3
        selection = txt[..2].replace(/t/g, 'u')
        cod = GenBank.codons[selection]
        if cod?
            codons += cod
        else
            codons += 'X'
        txt = txt[3..]
    return codons

  annotateFeature: (seq, feature) ->
    console.groupCollapsed("Annotating the feature: ", feature)
    color = feature.parameters["/ApEinfo_fwdcolor"]
    if feature.location.strand == 1
      color = feature.parameters["/ApEinfo_revcolor"]
    name = feature.parameters["/label"]
    for span in feature.location.ranges
      seq = @annotateOld(seq, span.start, span.end, color, name, span.id, feature.id)
    console.groupEnd()
    seq
 
  annotate: (sequence, start, end, color, features, id) ->
    console.groupCollapsed("Adding annotation #{id} to sequence: (#{start}..#{end})")
    if typeof(start) != "number"
      start = parseInt(start) - 1
    if typeof(end) != "number"
      end = parseInt(end) - 1
    count = true
    current = 0
    startix = -1
    endix = -1
    for x in [0..sequence.length]
      if sequence[x] == "<"
        count = false
      if current == start
        startix = x
      if current == end
        endix = x
      if count
        current += 1
      if sequence[x] == ">"
        count = true
    if startix == -1 or endix == -1
      console.error("End index or start index not found...", startix, endix)
      if current == start
        startix = x
      if current == end
        endix = x
    console.log(startix, endix)
    beg = sequence[...startix]
    end = sequence[endix+1..]
    mid = sequence[startix..endix]
    data_features = ""
    data_offsets = ""
    for parts in features
        feat = parts.feature
        span = parts.range
        offset = start - span.start
        if data_features != ""
            data_features += ","
            data_offsets += ","
        data_features += "#{feat.id}:#{span.id}"
        data_offsets += "#{feat.id}:#{offset}"

    console.groupEnd()
    beg + "<span id='#{id}-#{@id}' style='background-color:#{color}' data-offsets='#{data_offsets}' data-features='#{data_features}'>" + mid + "</span>" + end

  annotateRange: (seq, range, i = 0) ->
    console.groupCollapsed("Annotating range: ", range)
    r = range.feats[range.feats.length - 1]
    feat = r.feature
    span = r.range
    console.log("The feature: ", feat, "is on top")
    color = feat.parameters['/ApEinfo_fwdcolor']
    if feat.location.strand == 1
        color = feat.parameters['/ApEinfo_revcolor']
    name = feat.parameters["/label"]
    seq = @annotate(seq, range.selection.start, range.selection.end, color, range.feats, i)
    console.groupEnd()
    seq

  @findRangeById: (ranges, spanId) ->
    if ranges.uid == spanId
      return ranges
    for range in ranges
      r = GenBank.findRangeById(range, spanId)
      return r if !!r
    return null

  sortByStartIndex: (a, b) ->
    if a.start == b.start
      return 0
    if a.start > b.start
      return 1
    else
      return -1

  splitRangeAt: (featId, rangeId, newLength) ->
    console.groupCollapsed("Splitting range",featId,rangeId,"at",newLength)
    f = @getFeatures()[featId]
    r = GenBank.getRange(f.location, rangeId)

    # push new range
    f.location.ranges.push
        start: newLength + 1
        end: r.end
        id: f.location.ranges.length

    # update end point of current range
    r.end = newLength
    f.location.ranges.sort(@sortByStartIndex)
    console.groupEnd()
    f

  @getSpanData: (node) ->
    offsets = node.getAttribute('data-offsets').split(',')
    features = node.getAttribute('data-features').split(',')
    data = {}
    for offset in offsets
      split = offset.split(':')
      data[split[0]] or= {}
      data[split[0]]['offset'] = parseInt(split[1])
    for feature in features
      split = feature.split(':')
      data[split[0]] or= {}
      data[split[0]]['span'] = parseInt(split[1])
    return data

  splitFeatureAtInPlace: (featId, rangeId, newLength) ->
    console.groupCollapsed("Splitting feature",featId,rangeId,"at",newLength)
    f = @getFeatures()[featId]
    rangeIx = GenBank.rangeIndex(f, rangeId)
    newFeat = $.extend(true, {}, f)
    newFeat.id = f.id + 1
    newFeat.location.ranges[rangeIx].start += newLength + 1
    newFeat.location.ranges = newFeat.location.ranges[rangeIx..]
    console.log(newFeat.location.ranges[0].start)
    console.log(newFeat.location.ranges[0].end)
        
    r = f.location.ranges[rangeIx]
    r.end = r.start + newLength
    f.location.ranges = f.location.ranges[..rangeIx]
    
    pre = @getFeatures()[..featId]

    post = @getFeatures()[featId+1..]
    for feat in post
      feat.id += 1
    pre.push newFeat
    features = @getFeatures() 
    
    @data.features = pre.concat post

    console.groupEnd()
    new: newFeat
    old: f

  splitFeatureAt: (featId, rangeId, newLength) ->
    console.groupCollapsed("Splitting feature",featId,rangeId,"at",newLength)
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
    console.groupEnd()

    new: newFeat
    old: f

  moveEndBy: (featId, rangeId, amount) ->
    console.groupCollapsed("Moving end of #{featId}-#{rangeId}")
    f = @getFeatures()[featId]
    r = GenBank.getRange(f.location, rangeId)
    r.end += amount
    if r.end < r.start
      f.location.ranges.splice(GenBank.rangeIndex(f, rangeId), 1)
    console.groupEnd()

  advanceFeature: (featId, rangeId, amount) ->
    console.groupCollapsed("Advancing #{featId}-#{rangeId}")
    f = @getFeatures()[featId]
    r = GenBank.getRange(f.location, rangeId)
    r.start += amount
    r.end += amount
    console.groupEnd()

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

  getTableOfFeatures: () ->
    seq = @getGeneSequence()
    features = @getFeatures()
    selections = new Array(seq.length)
    for feature in features
        for range in feature.location.ranges
            for i in [range.start..range.end] by 1
                if selections[i] == undefined
                    selections[i] = []
                selections[i].push(feature: feature, range: range)
    selections

  getAnnotatedSequence: () ->
    seq = @getGeneSequence()
    selections = @getTableOfFeatures()
    ranges = []
    previous = undefined
    sel = start: 0, end: 0
    i = 0
    for selection in selections
        eq = (previous != undefined and selection != undefined)
        if eq and (previous.length != selection.length)
            eq = false
        if eq
            for j in [0...selection.length]
                s = selection[j]
                p = previous[j]
                if s.range != p.range or s.feature != p.feature
                    eq = false
        if eq
            sel.end = i
        else
            if previous != undefined
                ranges.push(feats: previous, selection: sel)
            previous = selection
            sel = start: i, end: i
        i += 1
    if previous != undefined
        ranges.push(feats: previous, selection: sel)

    rangeId = 0
    for range in ranges
        seq = @annotateRange(seq, range, rangeId)
        rangeId += 1

    # for feature in features
      # seq = @annotateFeature(seq, feature)
    console.groupEnd()
    seq

  getGeneSequence: () ->
    if @data.raw_genes?
      return @data.raw_genes
    console.groupCollapsed("Getting gene sequence")
    retval = ""
    for line in @data.ORIGIN.split(@newline)
      retval += line.split(/[ ]*[0-9]* /)[1..].join("")
    console.debug("Gene sequence constructed")
    console.groupEnd()
    @data.raw_genes = retval

  updateSequence: (seq) ->
    @data.raw_genes = seq

  @serializeLocation: (loc) ->
    console.groupCollapsed("Serializing Location")
    retval = ""
    for range in loc.ranges
      console.log("Adding range", range)
      retval += "," if retval != ""
      retval += "#{range.start+1}..#{range.end+1}"
    if loc.ranges.length > 1
      console.log("It's a join")
      retval = "join(#{retval})"
    if loc.strand == 1
      console.log("It's a complement")
      retval = "complement(#{retval})"
    console.groupEnd()
    retval

  serialize: () ->
    console.groupCollapsed("Serializing File")
    file = "LOCUS".padBy(12) + @data.LOCUS.name.padBy(13)
    file += (@getGeneSequence().length + " bp").padBy(11)
    file += @data.LOCUS.type.padBy(16) + @data.LOCUS.division + " "
    file += @data.LOCUS.date + @newline
    ignoredSections = ["LOCUS", "FEATURES", "ORIGIN", "//", "raw_genes",
                       "features"]
    # file = "LOCUS".padBy(12) + @data.LOCUS + @newline
    for own section,contents of @data
      if ignoredSections.indexOf(section) == -1
        file += section.padBy(12) + contents + @newline
    file += @serializeFeatures()
    file += @serializeGenes()
    console.groupEnd()
    file

  serializeFeatures: () ->
    console.groupCollapsed("Serializing Features")
    feats = @getFeatures()
    features = ""
    if feats.length > 0
      features = "FEATURES             Location/Qualifiers" + @newline
      for feat in feats
        if feat.location.ranges.length > 0
          features += "     " + feat.currentFeature.padBy(16) + GenBank.serializeLocation(feat.location) + @newline
          for own key, value of feat.parameters
            features += "                     " + "#{key}=\"#{value}\" " + @newline
    console.groupEnd()
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
    console.groupCollapsed("Parsing Location Data")
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

    console.groupEnd()

    retval =
      strand: strand
      ranges: ranges

  getFeatures: () ->
    if @data.features?
      return @data.features
    console.groupCollapsed("Getting features")
    retval = []
    currentFeature = ""
    components = ""
    parts = {}

    id = 0

    console.groupCollapsed("Looking at each feature")
    lines = []
    lines = @data.FEATURES.split(@newline)[1..] if @data.FEATURES?
    for line in lines
      if line.trim()[0] != "/"
        console.debug("This is the start of a new feature")
        if currentFeature != ""
          console.debug("Storing old feature")
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
        console.debug("Adding",line)
        s = line.trim().split("=")
        parts[s[0]] = s[1][1..-2]

    console.groupEnd()
    if currentFeature != ""
      retval.push
        currentFeature: currentFeature
        location: components
        parameters: parts
        id: id
    console.debug("Here's your features sir!")
    console.groupEnd()
    @data.features = retval

  #Replaces the range with repText does not take negative indicies
  replaceSequence: (repText, startIndex = 0, endIndex = -1) ->
    text = @getGeneSequence()
    if endIndex == -1
      endIndex = text.length

    begin = text.substring(0, startIndex)
    end =  text.substring(endIndex, text.length)
    
    @data.raw_genes = begin + repText + end
    console.log(@data.raw_genes)
    @data.raw_genes
