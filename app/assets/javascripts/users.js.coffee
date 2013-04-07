jQuery.fn.slideHide = (peek = 20) ->
  wid = $(this).outerWidth()
  position = peek - wid
  $(this).stop().animate(right:position, 'slow')

jQuery.fn.registerSlideHide = (peek = 20) ->
  $(this).hover (->
                  $(this).stop().animate right:0, 'slow'),
                (->
                  $(this).slideHide(peek))

  me = this
  setTimeout (-> $(me).slideHide(peek)), 3000
