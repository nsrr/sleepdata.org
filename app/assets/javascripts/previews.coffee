$(document)
  .on('click', '[data-object~="view-content-preview"]', () ->
    $('[data-object~="view-content-preview"]').addClass('active')
    $('[data-object~="view-content-markdown"]').removeClass('active')
    $.post(root_url + 'preview', { "content": $($(this).data('content')).val() }, null, "script")
    false
  )
  .on('click', '[data-object~="view-content-markdown"]', () ->
    $('[data-object~="view-content-markdown"]').addClass('active')
    $('[data-object~="view-content-preview"]').removeClass('active')
    $("#content_preview").hide();
    $("#content_markdown").show();
    false
  )
  .on('keydown', '[data-object~="expandable-text-area"]', (e) ->
    if e.which == 13
      numberOfLineBreaks = ($(this).val().match(/\n/g)||[]).length + 2
      if numberOfLineBreaks > 25
        $(this).attr('rows', 25)
      else if numberOfLineBreaks > $(this).data('default-rows')
        $(this).attr('rows', numberOfLineBreaks)
      else
        $(this).attr('rows', $(this).data('default-rows'))
  )
  .on('keyup', '[data-object~="expandable-text-area"]', (e) ->
    if e.which == 8 || e.which == 46
      numberOfLineBreaks = ($(this).val().match(/\n/g)||[]).length + 1
      if numberOfLineBreaks > 25
        $(this).attr('rows', 25)
      else if numberOfLineBreaks > $(this).data('default-rows')
        $(this).attr('rows', numberOfLineBreaks)
      else
        $(this).attr('rows', $(this).data('default-rows'))
  )
