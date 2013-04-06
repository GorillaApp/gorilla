window.register_notifications = ->
  $('.notification').each ->
    if $(this).text() != ""
      $(this).show()
  setTimeout (->
                $('.notification').fadeOut 'slow', ->
                  $(this).text("")
             ), 3000

window.notify = (message, type="notice") ->
  console.log message
  $(".notification##{type}").text(message)
  register_notifications()
