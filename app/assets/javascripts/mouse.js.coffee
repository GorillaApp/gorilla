window.G or= {}

class Mouse
  @_setCaretAt: (node, location) ->
    sel = window.getSelection()
    sel.removeAllRanges()
    l = document.createRange()
    l.setStart(node, location)
    l.collapse(true)
    sel.addRange(l)

  @_select: (startNode, startLocation, endNode, endLocation) ->
    sel = window.getSelection()
    sel.removeAllRanges()
    l = document.createRange()
    l.setStart(startNode, startLocation)
    l.setEnd(endNode, endLocation)
    sel.addRange(l)

  @_getNodeAndOffset: (container, index) ->
    if typeof container == "string"
      container = $(container).get(0)
    count = 0
    for node in container.childNodes
      if node.nodeName == "SPAN"
        node = node.childNodes[0]
      if count + node.length < index
        count += node.length
      else
        offset = index - count
        return node: node, offset: offset
    return null

  @setCaretIndex: (container, index) ->
    pos = Mouse._getNodeAndOffset(container, index)
    if pos != null
      Mouse._setCaretAt(pos.node, pos.offset)
      return true
    return false

  @selectIndices: (container, start, end) ->
    s = Mouse._getNodeAndOffset(container, start)
    e = Mouse._getNodeAndOffset(container, end)
    if s != null and e != null
      Mouse._select(s.node, s.offset, e.node, e.offset)
      return true
    return false
  
  @_getAbsoluteOffset: (node, offset) ->
    if node.parentNode.nodeName != "DIV"
      node = node.parentNode
    node = node.previousSibling

    while !!node
      offset += $(node).text().length
      node = node.previousSibling
    return offset

    
  @getCursorPosition: () ->
    sel = window.getSelection()
    if sel.rangeCount > 0
      r = sel.getRangeAt(0)
      retval = {}
      if r.collapsed
        retval.type = "caret"
        retval.start = Mouse._getAbsoluteOffset(r.startContainer, r.startOffset)
      else
        retval.type = "range"
        retval.start = Mouse._getAbsoluteOffset(r.startContainer, r.startOffset)
        retval.end = Mouse._getAbsoluteOffset(r.endContainer, r.endOffset)
      return retval
    return false


G.Mouse = Mouse
