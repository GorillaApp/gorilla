window.register_notifications = ->
  setTimeout (-> $('.notification').fadeOut('slow')), 3000

window.notify = (message) ->
  console.log message
