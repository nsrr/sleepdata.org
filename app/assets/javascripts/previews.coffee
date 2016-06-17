# TODO: Review all methods to see if each is necessary.

@numberOfHardAndSoftLineBreaks = (element) ->
  mWidth = 25/3
  lineWidth = $(element).innerWidth()
  string = $(element).val()
  array = string.split('\n')
  lineBreaks = array.length # Hard Breaks
  $.each(array, (index, line) ->
    lineBreaks += Math.floor((mWidth * line.length) / lineWidth) # Soft Wraps
  )
  return lineBreaks

$(document)
  .on('click', '[data-object~="view-content-preview"]', () ->
    $('[data-object~="view-content-preview"]').addClass('active')
    $('[data-object~="view-content-markdown"]').removeClass('active')
    $.post("#{root_url}preview",
      { 'content': $($(this).data('content')).val() }, null, 'script')
    false
  )
  .on('click', '[data-object~="view-content-markdown"]', () ->
    $('[data-object~="view-content-markdown"]').addClass('active')
    $('[data-object~="view-content-preview"]').removeClass('active')
    $('#content_preview').hide()
    $('#content_markdown').show()
    false
  )
  .on('input', '[data-object~="expandable-text-area"]', (e) ->
    numberOfLineBreaks = numberOfHardAndSoftLineBreaks($(this))
    if numberOfLineBreaks > 25
      $(this).attr('rows', 25)
    else if numberOfLineBreaks > $(this).data('default-rows')
      $(this).attr('rows', numberOfLineBreaks)
    else
      $(this).attr('rows', $(this).data('default-rows'))
  )
