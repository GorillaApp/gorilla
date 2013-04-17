window.getCharSize = (fontFamily, fontSize) ->
    div = document.createElement("div")
    div.style.position = "absolute"
    div.style.visibility = "hidden"
    div.style.fontFamily = fontFamily
    div.style.fontSize = fontSize
    div.innerHTML = "S"
    document.body.appendChild(div)
    width = div.offsetWidth
    height = div.offsetHeight
    document.body.removeChild(div)
    return width: width, height: height
