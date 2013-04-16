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
getSpansFromHtml = () ->
  spans = $(s).each(()->
    $span = $(this)
    divId = $span.closest('div').attr('id')
    spanId = $span.attr('id')
    spanTxt = $span.text()
  )
  return spans


window.getSelectionHtml = getSelectionHtml
window.getSpansFromHtml = getSpansFromHtml
