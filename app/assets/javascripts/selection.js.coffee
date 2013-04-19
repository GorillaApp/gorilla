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
  indices = GorillaEditor.getSelectionRange(sel)
  if indices.length == 2
    [sIndex, eIndex] = indices
  else
    return
  editor = GorillaEditor.getInstance(sel.anchorNode)
  allFeats = editor.file.getTableOfFeatures()
  seenFeatures = {}
  numSplits = 0

  console.log("Start index %d", sIndex)
  console.log("End index %d", eIndex)

  if allFeats[sIndex]
      for pair in allFeats[sIndex]
        feature = pair.feature
        range = pair.range
        distanceInRange = sIndex - range.start - 1
        console.log("Distance in range: %d", distanceInRange)
        if sIndex != range.start
          editor.file.splitFeatureAt(feature.id, range.id, distanceInRange)
          numSplits += 1
  
  allFeats = editor.file.getTableOfFeatures()
  if allFeats[eIndex]
      for pair in allFeats[eIndex]
        feature = pair.feature
        range = pair.range
        distanceInRange = eIndex - range.start - 1
        if (eIndex-1) != range.end
          editor.file.splitFeatureAt(feature.id, range.id, distanceInRange)
          console.log("eIndex: %d, range.end: %d", eIndex, range.end)
          numSplits += 1
  console.log("Number splits: %d", numSplits)
  allFeats = editor.file.getTableOfFeatures()
  eIndex -= 1
  console.log(allFeats[sIndex...eIndex])
  for i in [sIndex...eIndex]
    if allFeats[i]
        for pair in allFeats[i] #gives us a list of feat_id, range_id
          feature = pair.feature
          range = pair.range
          
          hash = feature.id.toString() + ',' + range.id.toString()
          if not seenFeatures[hash]
            seenFeatures[hash] = true
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
            feature.location.strand ^= 1
  modifySelection(revCompSeq)

revCompSeq = (seq) ->
  #debugger
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
G.modifySelection = modifySelection
G.reverseCompSelection = reverseCompSelection
G.revCompSeq = revCompSeq
