@ready = () ->
  $('[data-object~="form-load"]').submit()

$(document).ready(ready)
$(document).on('page:load', ready)

$(document).on('click', '#dataset-tabs a', (e) ->
  e.preventDefault()
  $(this).tab('show')
)

@setScrollShadow = (element) ->
  scroll = $(element).scrollTop();
  if scroll + $(element).innerHeight() == $(element)[0].scrollHeight
    $(element).removeClass("shadow-inset-bottom")
  else
    $(element).addClass("shadow-inset-bottom")

  if scroll == 0
    $(element).removeClass("shadow-inset-top")
  else
    $(element).addClass("shadow-inset-top")

jQuery ->
  $('.file-list-container').scroll( () ->
    setScrollShadow(this)
  )
  $('.file-list-container').each( (index, element) ->
    setScrollShadow($(element))
  )
