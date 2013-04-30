#= require heart

window.G or= {}
Heart = G.Heart

class Alignment
  @openFiles: () ->
    tabs = Heart.getAlive()
    retval = {}
    for name, tab of tabs
      if tab.sequence? and tab.filename?
        retval[name] = tab
    return retval
    
  @begin: () ->
    files = Alignment.openFiles()
    sequences = []
    for tab, file of files
      sequences.push([file.sequence, file.filename])
    $.post('/bio/align', {sequences:sequences}, (response) ->
      console.log response.raw)

window.G.Alignment = Alignment
