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

window.getSelectionHtml = getSelectionHtml
