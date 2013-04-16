window.namespace = (name) ->
    window[name] or= {}
    for variable of window[name]
        eval("#{variable} = window['#{name}']['#{variable}']")
