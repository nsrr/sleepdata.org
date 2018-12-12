@downloadFile = (index,element) ->
  $('[data-object~="autodownload"]')[index].click()

@datasetsReady = ->
  $('[data-object~="autodownload"]').each((index, element) ->
    setTimeout((() -> downloadFile(index, element)), 500)
  )

$(document)
  .on('click', '[data-object~="toggle-page-list"]', ->
    $('.page-list-container').toggle()
    $('#show-page-button').toggle()
    $('#hide-page-button').toggle()
    $('#documentation-content').toggleClass('col-md-12 col-md-9')
    $('#sidebar-content').toggleClass('col-md-3')
    false
  )
