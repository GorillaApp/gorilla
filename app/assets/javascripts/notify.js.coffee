jQuery.fn.sortByAttr = (tag) ->
  $(this).sort (a, b) ->
    aVal = parseInt($(a).attr(tag))
    bVal = parseInt($(b).attr(tag))
    return -1 if aVal < bVal
    return 1 if aVal > bVal
    return 0

window.register_notifications = ->
  registered_notifications = []

  offsets =
    status: 0
    other: 0
  $('.notification DIV').sortByAttr('data-order').each ->
    me = @
    $(me).hide()
    $(me).css('bottom', "")
    $(me).css('top', "")
    if $(me).attr('data-duration') == undefined
      $(me).attr('data-duration', '3000')
    if $.inArray($(me).text(), registered_notifications) == -1
      $(me).show()
      if $(me).hasClass('status')
        $(me).css('bottom', "+=#{offsets.status}")
        offsets.status += $(me).outerHeight()
      else
        $(me).css('top', "+=#{offsets.other}")
        offsets.other += $(me).outerHeight()
      registered_notifications.push($(me).text())
      setTimeout (->
        $(me).fadeOut('slow', (->
          registered_notifications.pop()
          $(this).remove()
          register_notifications()
          ))), parseInt($(me).attr('data-duration'))

window.notify = (message, type="status", duration="3000" ) ->
  console.log message
  id = $(".notification DIV").length
  $(".notification").append("<div data-duration='#{duration}' data-order='#{id}' class='#{type}'>#{message}</div>")
  register_notifications()
