window.G or= {}

class LocalStorage
  @get: (ids...) ->
    prefix = ids.join("-")
    retval = {}
    dataFound = false
    for own key, value of localStorage
      if key == prefix
        return value
      if key.indexOf(prefix) == 0
        dataFound = true
        if prefix.length > 0
          keyRemains = key[prefix.length + 1..]
        else
          keyRemains = key
        keyRemains = keyRemains.split('-')
        obj = retval
        for newkey in keyRemains[...-1]
          if not obj[newkey]?
            obj[newkey] = {}
          obj = obj[newkey]
        obj[keyRemains[keyRemains.length - 1]] = value
    if dataFound
      return retval
    return ""

  @store: (ids..., data) ->
    prefix = ids.join("-")
    if typeof data == "object"
      for own key, value of data
        newids = ids.slice(0)
        newids.push(key)
        LocalStorage.store(newids, value)
    else
      localStorage[prefix] = data

  @delete: (ids...) ->
    prefix = ids.join("-")
    for own key, value of localStorage
      if key.indexOf(prefix) == 0
        delete localStorage[key]

G.LocalStorage = LocalStorage
