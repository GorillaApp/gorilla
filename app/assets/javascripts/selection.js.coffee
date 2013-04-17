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
    #text = node.innerHTML
    return [featureId, rangeId]
  else
    return node

getFeatureDataOfSelected = () ->
  nodeData = []
  [selectedHtml, sel] = getSelectionHtml()
  nodes = []
  textNodes = []

  i = 0
  j = selectedHtml.length - 1
  #finishes when it either finds a < or it equals the length
  while selectedHtml[i] != '<' and i < selectedHtml.length
    i += 1
  while selectedHtml[j] != '>' and j > 0
    j -= 1

  # if it is completely a text node, push its container, the span
  if i == selectedHtml.length
    nodes = [sel.anchorNode.parentNode]
  else
    nodes = getNodesFromHtmlText(selectedHtml)

  console.log(nodes)
    #else
    #if i != 0 # if it begins with a text node
    #text = selectedHtml.substr(0,i)
      #textNodes.push text
      #      selectedHtml = selectedHtml[i..]

    #nodes = textNodes.concat 
  for node in nodes
    nodeDatum = getNodeData(node)
    console.log(nodeDatum)
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
