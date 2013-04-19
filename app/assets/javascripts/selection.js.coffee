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

toUpper = (inputString) ->
    return inputString.toUpperCase()

reverseCompSelection = () ->
  #nothing is here yet

window.G or= {}
window.G.toUpper = toUpper
window.G.modifySelection = modifySelection
