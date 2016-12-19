@drawRating = (rating) ->
  $('[data-object~="star-rating"]').each( ->
    if $(this).data('position') < rating
      $(this).removeClass('text-muted')
      $(this).removeClass('fa-star-o')
      $(this).addClass('fa-star')
      $(this).addClass('text-warning')
    else
      $(this).removeClass('text-warning')
      $(this).removeClass('fa-star')
      $(this).addClass('fa-star-o')
      $(this).addClass('text-muted')
  )

$(document)
  .on('click', '[data-object~="star-rating"]', ->
    rating = $(this).data('position') + 1
    $('#community_tool_review_rating').val(rating)
    drawRating(rating)
    false
  )
  .on('mouseenter', '[data-object~="star-rating"]', ->
    return false unless document.documentElement.ontouchstart == undefined
    rating = $(this).data('position') + 1
    drawRating(rating)
  )
  .on('mouseleave', '[data-object~="star-rating"]', ->
    rating = $('#community_tool_review_rating').val()
    drawRating(rating)
  )
