@showcaseReady = () ->
  $(".showcase-item-picture").hover ->
    $(this).toggleClass "img-bw"
    $(this).toggleClass "img-bw-partial"
    return

  $(".showcase-item-picture").click ->
    $(".showcase-item-picture").removeClass "img-color"
    $(this).toggleClass "img-color"
    return


$(document)
  .on('slide.bs.carousel', $('#carousel-showcase'), (event) ->
    $(".showcase-item-picture").removeClass "img-color"
    item_position = $(event['relatedTarget']).index()
    $("#showcase-list li:eq(#{item_position}) img").toggleClass "img-color"
  )
