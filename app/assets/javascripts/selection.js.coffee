GenBank = window.G.GenBank #Import
GorillaEditor = window.G.GorillaEditor

modifySelection = (modFunction, trackChanges = true, sel = null) ->
  if sel
    indices = [sel.start, sel.end]
    collapseFlag = false
  else
    sel = window.getSelection()
    indices = GorillaEditor.getSelectionRange(sel)
    collapseFlag = true

  editor = window.G.main_editor


  if indices.length == 2
    [sIndex, eIndex] = indices
  else
    [sIndex, eIndex] = [0, editor.file.getGeneSequence().length]

  editor = G.main_editor
  if trackChanges
    editor.trackChanges()

  data = editor.file.getGeneSequence()
  subData = modFunction(data.substring(sIndex, eIndex))
  editor.file.replaceSequence(subData, sIndex, eIndex)

  $(editor.editorId).html(editor.file.getAnnotatedSequence())
  editor.completeEdit()
  
  if collapseFlag
    sel.collapse(true)

toUpper = (s) ->
  return s.toUpperCase()

toLower = (s) ->
  return s.toLowerCase()

reverseCompSelection = (testIndices, testGenbank, test = false, sel)->
  if test
    t = {}
    t['file'] = testGenbank
    revCompSelectionLogic(testIndices, t)
  else
    console.groupCollapsed("handlingRevCompSel")
    if sel
      indices = [sel.start, sel.end]
      editor = G.main_editor
    else
      sel = window.getSelection()
      indices = GorillaEditor.getSelectionRange(sel)
      editor = GorillaEditor.getInstance(sel.anchorNode)
    editor.trackChanges()
    revCompSelectionLogic(indices, editor)
    modifySelection(revCompSeq, false)
    console.groupEnd()

revCompSelectionLogic = (indices, editor) ->
  if indices.length == 2
    [sIndex, eIndex] = indices
    eIndex--
  else
    return
  
  seenFeatures = {}
  numSplits = 0
  allFeats = editor.file.getTableOfFeatures()
  console.log("Start index %d", sIndex)
  console.log("End index %d", eIndex)

  if allFeats[sIndex]
    for pair in allFeats[sIndex]
      feature = pair.feature
      range = pair.range
      distanceInRange = sIndex - range.start - 1
      if sIndex != range.start and feature.location.ranges.length == 1
        editor.file.splitFeatureAtInPlace(feature.id, range.id, distanceInRange)
        numSplits += 1
  
  allFeats = editor.file.getTableOfFeatures()
  if allFeats[eIndex]
    for pair in allFeats[eIndex]
      feature = pair.feature
      range = pair.range
      distanceInRange = eIndex - range.start
      if eIndex != range.end and feature.location.ranges.length == 1
        editor.file.splitFeatureAtInPlace(feature.id, range.id, distanceInRange)
        numSplits += 1

  allFeats = editor.file.getTableOfFeatures()
  for i in [sIndex .. eIndex]
    if allFeats[i]
      for pair in allFeats[i] #gives us a list of feat_id, range_id
        feature = pair.feature
        range = pair.range
        if not seenFeatures[feature] and feature.location.ranges.length > 1
          seenFeatures[feature] = true
          editor.file.splitJoinedFeature(feature, sIndex, eIndex)


  seenFeatureRanges = {}
  seenFeats = {}
  console.log("Number splits: %d", numSplits)
  allFeats = editor.file.getTableOfFeatures()
  console.log(allFeats[sIndex...eIndex])
  for i in [sIndex .. eIndex]
    if allFeats[i]
      for pair in allFeats[i] #gives us a list of feat_id, range_id
        feature = pair.feature
        range = pair.range
        
        hash = feature.id.toString() + ',' + range.id.toString()
        if not seenFeatureRanges[hash]
          seenFeatureRanges[hash] = true
          console.log("Initial range start %d", range.start)
          console.log("Initial range end %d", range.end)
          rangeLen = range.end - range.start
          offsetInSel = range.start - sIndex
          console.log("Offset in sel %d", offsetInSel)
          console.log("Start index %d", sIndex)
          console.log("End index %d", eIndex)
          range.start = eIndex - rangeLen - offsetInSel
          range.end = eIndex - offsetInSel
          console.log("New range start %d", range.start)
          console.log("New range end %d", range.end)
          notherHash = feature.id.toString()
          if not seenFeats[notherHash]
            seenFeats[notherHash] = true
            feature.location.strand ^= 1

revCompSeq = (seq) ->
  newSeq = ""
  i = seq.length - 1
  seqMap =
    a:"t", t:"a", c:"g", g:"c", n:"n"
    A:"T", T:"A", C:"G", G:"C", N:"N"
    y:"r", r:"y", b:"v", v:"b", s:"s"
    Y:"R", R:"Y", B:"V", V:"B", S:"S"
    d:"h", h:"d", m:"k", k:"m", w:"w"
    D:"H", H:"D", M:"K", K:"M", W:"W"

  while i >= 0
    newSeq += seqMap[seq[i]]
    i--
  return newSeq

window.bind_selections = ->
  $('#reverseComplement').unbind('click').click ->
    reverseCompSelection()
  $('#toUpper').unbind('click').click ->
    modifySelection(toUpper)
  $('#toLower').unbind('click').click ->
    modifySelection(toLower)

window.G or= {}

G.toUpper = toUpper
G.toLower = toLower
G.modifySelection = modifySelection
G.reverseCompSelection = reverseCompSelection
