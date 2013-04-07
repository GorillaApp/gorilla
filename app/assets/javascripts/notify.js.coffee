registered_notifications = []

jQuery.fn.sortByAttr = (tag) ->
  $(this).sort (a, b) ->
    aVal = parseInt($(a).attr(tag))
    bVal = parseInt($(b).attr(tag))
    return -1 if aVal < bVal
    return 1 if aVal > bVal
    return 0

window.register_notifications = ->
  offsets =
    status: 0
    other: 0
  $('.notification DIV').sortByAttr('data-order').each ->
    me = @
    $(me).css('bottom', "")
    $(me).css('top', "")
    if $.inArray($(me).text(), registered_notifications) == -1
      if $(me).hasClass('status')
        $(me).css('bottom', "+=#{offsets.status}")
        offsets.status += $(me).height()
      else
        $(me).css('top', "+=#{offsets.other}")
        offsets.other += $(me).height()

      $(me).show()
      registered_notifications.push($(me).text())
      setTimeout (->
        $(me).fadeOut('slow', (->
          registered_notifications.pop()
          $(this).remove()
          register_notifications()
          ))), 10000

window.notify = (message, type="notice") ->
  console.log message
  id = $(".notification DIV").length
  $(".notification").append("<div data-order='#{id}' class='#{type}'>#{message}</div>")
  register_notifications()
