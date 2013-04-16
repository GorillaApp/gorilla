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
  return html

# Credit to: StackOverflow user Pat
getNodesFromHtmlText = (htmlText) ->
  spans = $(htmlText).each(()->
    $span = $(this)
    divId = $span.closest('div').attr('id')
    spanId = $span.attr('id')
    spanTxt = $span.text()
  )
  return spans

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
  selectedHtml = getSelectionHtml()
  nodes = getNodesFromHtmlText(selectedHtml)
  
  for node in nodes
    nodeDatum = getNodeData(node)
    nodeData.push nodeDatum

  return nodeData

window.getFeatureDataOfSelected = getFeatureDataOfSelected
window.getSelectionHtml = getSelectionHtml
window.getNodesFromHtmlText = getNodesFromHtmlText
