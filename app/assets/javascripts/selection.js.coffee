# Current problems:
# getNodesFromHtmlText cannot handle if text node is first node
# in html data. Also, if text node is last node in html data it
# is simply ignored.

GenBank = window.G.GenBank #Import
GE = window.G.GorillaEditor

modifySelection = (modFunction) ->
  [sIndex, eIndex, editor] = getInfoFromSelection()
  data = editor.file.getGeneSequence()
  subData = data.substr(sIndex, eIndex).modFunction()
  editor.file.replaceSequence(data, subData, sIndex, eIndex)

window.G or= {}
G.getFeatureDataOfSelected = getFeatureDataOfSelected
G.getSelectionHtml = getSelectionHtml
G.getNodesFromHtmlText = getNodesFromHtmlText
