# Current problems:
# getNodesFromHtmlText cannot handle if text node is first node
# in html data. Also, if text node is last node in html data it
# is simply ignored.

# Credit to: StackOverflow user Tim Down
getSelectionHtml =  () ->
  sel = ""
  html = ""
  if window.getSelection
    sel = window.getSelection()
    if sel.rangeCount
      frag = sel.getRangeAt(0).cloneContents()
      el = document.createElement("div")
      el.appendChild(frag)
      html = el.innerHTML
    else if document.selection && document.selection.type == "Text"
      html = document.selection.createRange().htmlText
  return [html, sel]

# Credit to: StackOverflow user Pat
getNodesFromHtmlText = (htmlText) ->
  nodes = $(htmlText).each(()->
    $node = $(this)
    divId = $node.closest('div').attr('id')
    nodeId = $node.attr('id')
    nodeTxt = $node.text()
  )
  return nodes

getNodeData = (node) ->
  if node.nodeName == "SPAN"
    split_id = node.id.split('-')
    featureId = split_id[1]
    rangeId = split_id[2]
    text = node.innerHTML
    return [featureId, rangeId, text]
  else
    return node

getFeatureDataOfSelected = () ->
  nodeData = []
  [selectedHtml, sel] = getSelectionHtml()
  nodes = getNodesFromHtmlText(selectedHtml)
  
  for node in nodes
    nodeDatum = getNodeData(node)
    nodeData.push nodeDatum
  
  if nodeData.length > 0
    if sel.anchorOffset != 0
      nodeData[0].push sel.baseOffset
    else
      nodeData[0].push 0

    nodeData[nodeData.length - 1].push sel.extentOffset

  return nodeData

window.getFeatureDataOfSelected = getFeatureDataOfSelected
window.getSelectionHtml = getSelectionHtml
window.getNodesFromHtmlText = getNodesFromHtmlText
