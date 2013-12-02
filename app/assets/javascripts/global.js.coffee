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

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@ready = () ->
  $('[data-object~="form-load"]').submit()
  $('.file-list-container').scroll( () ->
    setScrollShadow(this)
  )
  setScrollShadow($('.file-list-container'))
  $("[rel=tooltip]").tooltip( trigger: 'hover' )

  setFocusToField("#collection_form #s")

@nonStandardClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey or event.shiftKey or event.altKey

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
  .on('click', '[data-object~="toggle-about-view"]', () ->
    if $('#about-list-view').is(':visible')
      $('#about-list-view').hide()
      $('#about-block-view').show()
      $(this).html('<span class="glyphicon glyphicon-list"></span>')
    else
      $('#about-block-view').hide()
      $('#about-list-view').show()
      $(this).html('<span class="glyphicon glyphicon-th"></span>')
    false
  )
  .on('click', "[data-link]", (e) ->
    if nonStandardClick(e) or $(this).attr('target') == '_blank'
      window.open($(this).data("link"))
      return false
    else
      window.location = $(this).data("link")
  )
  .on('click', "[data-basename]", () ->
    $.get(root_url + 'collection_modal', { "basename": $(this).data('basename'), slug: $(this).data('slug') }, null, "script")
    return false
  )
