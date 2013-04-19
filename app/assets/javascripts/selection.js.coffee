gb = window.G.GenBank #import
ONLY_TEXT = 1

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

# Credit to: StackOverflow user Tim Down
replaceSelectedText = (replacementText) ->
  if window.getSelection
    sel = window.getSelection()
    if sel.rangeCount
      range = sel.getRangeAt(0)
      range.deleteContents()
      range.insertNode(document.createTextNode(replacementText))
  else
    if document.selection && document.selection.createRange
      range = document.selection.createRange()
      range.text = replacementText

getNodesFromHtmlText = (htmlText) ->
  nodeData = []
  nodes = []
  textNodes = []

  i = 0
  j = htmlText.length - 1
  #finishes when it either finds a < or it equals the length
  while htmlText[i] != '<' and i < htmlText.length
    i += 1
  while htmlText[j] != '>' and j > 0
    j -= 1


  # if it is completely a text node, push its container, the span
  if i == htmlText.length
    # check if inside a feature, or just text (check parentNode)
    # If div, then pNode is the div
    candidate = sel.anchorNode.parentNode
    if candidate.nodeName == "DIV"
      # it was just pure text
      # replaceSelectedText(repText)
      return [htmlText]
    else
      return [candidate]
  else
    leadingText = htmlText[...i]
    trailingText = htmlText[j+1...]
    pureHtml = htmlText[i...j+1]
    
    console.log(leadingText)
    console.log(trailingText)
    console.log(pureHtml)

    if leadingText
      nodes.push leadingText
    
    # Credit to: StackOverflow user Pat
    spanNodes = $(pureHtml).each(()->
      $node = $(this)
      divId = $node.closest('div').attr('id')
      nodeId = $node.attr('id')
      nodeTxt = $node.text()
    )
    # credit boundary ends here

    nodes = nodes.concat spanNodes
    
    if trailingText
      nodes.push trailingText
    # At this point, it could have choked if there html had leading text
    # or it will have ignored the trailing text
    # On success, gives us an ordered list of spans and text nodes in the selection
    
    # if i or j are non-zero, then there was trailing or leading text
    # if this is the case, look at the first and last span to figure out which case we're in
    # Furthermore, take their global offsets and either subtract i from the first one or add j to the last one 
    # to get the global offsets of the entire selection
  return nodes

getFeatureDataOfSelected = () ->
  [selectedHtml, sel] = getSelectionHtml()
  nodes = getNodesFromHtmlText(selectedHtml) 
  console.log(nodes)
  return
  # nexted dictionary
  # keys are feature id's
  # this gives a new dictionary
  # with keys 'span' and 'offset'
  # the 'span' entry is the range id
  # the 'offset' entry is the offset in the range of this span
  featureInfo = gb.getSpanData(node)
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

window.G.getFeatureDataOfSelected = getFeatureDataOfSelected
window.G.getSelectionHtml = getSelectionHtml
window.G.getNodesFromHtmlText = getNodesFromHtmlText
