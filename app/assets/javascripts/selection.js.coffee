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
  modifySelection(revCompSeq)
  [sIndex, eIndex] = GorillaEditor.getSelectionRange()
  feats = editor.file.getTableOfFeatures()
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

window.G or= {}

G.toUpper = toUpper
G.modifySelection = modifySelection
G.reverseCompSelection = reverseCompSelection
G.revCompSeq = revCompSeq
