@drawRating = (rating) ->
  $('[data-object~="star-rating"]').each( ->
    icon = $(this).find('i')
    if $(this).data('position') < rating
      icon.removeClass('text-muted')
      icon.removeClass('fa-star-o')
      icon.addClass('fa-star')
      icon.addClass('text-warning')
    else
      icon.removeClass('text-warning')
      icon.removeClass('fa-star')
      icon.addClass('fa-star-o')
      icon.addClass('text-muted')
  )

$(document)
  .on('click', '[data-object~="star-rating"]', ->
    rating = $(this).data('position') + 1
    $($(this).data('target')).val(rating)
    drawRating(rating)
    false
  )
  .on('mouseenter', '[data-object~="star-rating"]', ->
    return false unless document.documentElement.ontouchstart == undefined
    rating = $(this).data('position') + 1
    drawRating(rating)
  )
  .on('mouseleave', '[data-object~="star-rating"]', ->
    rating = $($(this).data('target')).val()
    drawRating(rating)
  )
