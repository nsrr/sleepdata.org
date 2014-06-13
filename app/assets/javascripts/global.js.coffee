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
  contourReady()
  $('.file-list-container').scroll( () ->
    setScrollShadow(this)
  )
  setScrollShadow($('.file-list-container'))
  $("[rel=tooltip]").tooltip( trigger: 'hover' )
  setFocusToField("#collection_form #s, #page_name, #search_form #s, #search, #collection_form #s, #s")
  $("img.lazy").lazyload( effect : "fadeIn" )
  Turbolinks.allowLinkExtensions('md')
  # Turbolinks.enableTransitionCache()
  prettyPrint()
  variablesReady() if (typeof variablesReady == 'function')

$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('click', '[data-object~="submit"]', () ->
    $($(this).data('target')).submit()
    false
  )
  .on('click', "[data-basename]", () ->
    $.get(root_url + 'collection_modal', { "basename": $(this).data('basename'), slug: $(this).data('slug'), d: $(this).data('d') }, null, "script")
    return false
  )
  .on('click', '[data-object~="hide-target"]', () ->
    $($(this).data('target')).hide()
  )
  .on('click', '[data-object~="show-target"]', () ->
    $($(this).data('target')).show()
  )

$(window).scroll( () ->
  $('.si').each( () ->
    imagePos = $(this).offset().top
    bottomOfWindow = $(window).scrollTop() + $(window).height()
    $(this).addClass("slideUp") if imagePos < bottomOfWindow - 200
  )
)


$(document)
  .on('touchstart', (e) ->
    window.$xDown = e.originalEvent.touches[0].pageX
    window.$yDown = e.originalEvent.touches[0].pageY
  )
  .on('touchmove', (e) ->
    return if ! window.$xDown || ! window.$yDown

    xUp = e.originalEvent.touches[0].pageX
    yUp = e.originalEvent.touches[0].pageY

    xDiff = window.$xDown - xUp
    yDiff = window.$yDown - yUp

    if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) # most significant
      if ( xDiff > 0 )
        # Left Swipe
        $('#next-variable')[0].click() if $('#next-variable')[0]
      else
        # Right Swipe
        $('#previous-variable')[0].click() if $('#previous-variable')[0]
    else
      if ( yDiff > 0 )
        # up swipe
      else
        # down swipe
    window.$xDown = null
    window.$yDown = null
  )
