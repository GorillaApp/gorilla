#= require local-storage

window.G or= {}
LocalStorage = G.LocalStorage

class Heart
  @start: (id) ->
    setInterval (() -> Heart.beat(id)), 500

  @beat: (id) ->
    LocalStorage.store(id, 'heartbeat', new Date().getTime())

  @isAlive: (id) ->
    lastSeen = LocalStorage.get(id, 'heartbeat')
    if lastSeen?
      if ((new Date().getTime()) - lastSeen) < 1000
        return true
      else
        LocalStorage.delete(id)
    return false

  @getAlive: () ->
    retval = {}
    for own key, value of LocalStorage.get()
      if Heart.isAlive(key)
        retval[key] = value
    return retval

G.Heart = Heart
