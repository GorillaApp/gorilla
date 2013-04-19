GenBank = window.G.GenBank #Import
GorillaEditor = window.G.GorillaEditor

modifySelection = (modFunction) ->
  sel = window.getSelection()
  [sIndex, eIndex] = GorillaEditor.getSelectionRange(sel)
  if sIndex and eIndex
    editor = GorillaEditor.getInstance(sel.anchorNode)
    data = editor.file.getGeneSequence()
    console.log(sIndex)
    console.log(eIndex)
    console.log(data.substring(sIndex, eIndex))
    subData = modFunction(data.substring(sIndex, eIndex))
    editor.file.replaceSequence(subData, sIndex, eIndex)
    console.log(editor.editorId)
    $(editor.editorId).html(editor.file.getAnnotatedSequence())

toUpper = (inputString) ->
    return inputString.toUpperCase()

reverseCompSelection = () ->
  modifySelection(revCompSeq)
  [sIndex, eIndex] = GorillaEditor.getSelectionRange()
  feats = editor.file.getTableOfFeatures()
  console.log(feats)

revCompSeq = (seq) ->
  newSeq = ""
  i = seq.length - 1
  seqMap = a:"t", t:"a", c:"g", g:"c", n:"n"
           A:"T", T:"A", C:"G", G:"C", N:"N"

  while i > 0
    newSeq += seqMap[seq[i]]
    i--
  return newSeq

window.G or= {}

G.toUpper = toUpper
G.modifySelection = modifySelection
G.reverseCompSelection = reverseCompSelection
