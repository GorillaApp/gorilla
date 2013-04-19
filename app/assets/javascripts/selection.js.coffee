GenBank = window.G.GenBank #Import
GorillaEditor = window.G.GorillaEditor

modifySelection = (modFunction) ->
  [sIndex, eIndex] = GE.getSelectionRange()
  if sIndex and eIndex
    sel = window.getSelection()
    editor = GorillaEditor.getInstance(sel.anchorNode)
    data = editor.file.getGeneSequence()
    subData = data.substr(sIndex, eIndex).modFunction()
    editor.file.replaceSequence(subData, sIndex, eIndex)
    $(editor.editorID).html(GenBank.getAnnotatedSequence())

reverseCompSelection = () ->
  #nothing is here yet

window.G or= {}
