GenBank = window.G.GenBank #Import
GorillaEditor = window.G.GorillaEditor

modifySelection = (modFunction) ->
  sel = window.getSelection()
  indices = GorillaEditor.getSelectionRange(sel)
  if indices.length == 2
    [sIndex, eIndex] = indices
    editor = GorillaEditor.getInstance(sel.anchorNode)
    data = editor.file.getGeneSequence()
    console.log(sIndex)
    console.log(eIndex)
    console.log(data.substring(sIndex, eIndex))
    subData = modFunction(data.substring(sIndex, eIndex))
    editor.file.replaceSequence(subData, sIndex, eIndex)
    console.log(editor.editorId)
    $(editor.editorId).html(editor.file.getAnnotatedSequence())

toUpper = (s) ->
  return s.toUpperCase()

toLower = (s) ->
  return s.toLowerCase()

reverseCompSelection = () ->
  sel = window.getSelection()
  [sIndex, eIndex] = GorillaEditor.getSelectionRange(sel)
  editor = GorillaEditor.getInstance(sel.anchorNode)
  allFeats = editor.file.getTableOfFeatures()
  seenFeatures = {}

  for pair in allFeats[sIndex]
    feature = pair.feature
    range = pair.range
    distanceInRange = sIndex - range.start
    if sIndex != range.start
      editor.file.splitFeatureAt(feature.id, range.id, distanceInRange)
  
  allFeats = editor.file.getTableOfFeatures()
  for pair in allFeats[eIndex]
    feature = pair.feature
    range = pair.range
    distanceInRange = eIndex - range.start
    if eIndex != range.end
      editor.file.splitFeatureAt(feature.id, range.id, distanceInRange)
  
  allFeats = editor.file.getTableOfFeatures()
  for i in [sIndex..eIndex]
    for pair in allFeats[i] #gives us a list of feat_id, range_id
      feature = pair.feature
      range = pair.range
      
      hash = feature.id.toString() + ',' + range.id.toString()
      if not seenFeatures[hash]
        seenFeatures[hash] = true
        rangeLen = range.end - range.start
        offsetInSel = sIndex - range.start
        range.start = eIndex - rangeLen - offsetInSel
        range.end = offsetInSel
        feature.location.strand ^= 1
      
  modifySelection(revCompSeq)
  console.log(feats)

revCompSeq = (seq) ->
  #debugger
  newSeq = ""
  i = seq.length - 1
  seqMap = 
    a:"t", t:"a", c:"g", g:"c", n:"n"
    A:"T", T:"A", C:"G", G:"C", N:"N"

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
G.modifySelection = modifySelection
G.reverseCompSelection = reverseCompSelection
G.revCompSeq = revCompSeq
