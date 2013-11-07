@setScrollShadow = (element) ->
  return unless $(element)[0]
  scroll = $(element).scrollTop();
  if scroll + $(element).innerHeight() == $(element)[0].scrollHeight
    $(element).removeClass("shadow-inset-bottom")
  else
    $(element).addClass("shadow-inset-bottom")

  if scroll == 0
    $(element).removeClass("shadow-inset-top")
  else
    $(element).addClass("shadow-inset-top")

@ready = () ->
  $('[data-object~="form-load"]').submit()
  $('.file-list-container').scroll( () ->
    setScrollShadow(this)
  )
  setScrollShadow($('.file-list-container'))
  $("[rel=tooltip]").tooltip( trigger: 'hover' )

$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('click', '[data-object~="submit"]', () ->
    $($(this).data('target')).submit()
    false
  )
  .on('mouseover', '[data-object~="hover-highlight"]', () ->
    $($(this).data('targetfade')).addClass('leadership-fade')
    $($(this).data('targethighlight')).addClass('leadership-highlight')
  )
  .on('mouseout', '[data-object~="hover-highlight"]', () ->
    $($(this).data('targetfade')).removeClass('leadership-fade')
    $($(this).data('targethighlight')).removeClass('leadership-highlight')
  )
