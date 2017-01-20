$(document)
  .on('click', '[data-object~="toggle-sign-up"]', ->
    $('#sign-up-form').toggle()
    $('#sign-in-form').toggle()
    false
  )
  .on('click', '[data-object~="submit-tool-draft"]', ->
    $('#draft').val('1')
    $($(this).data('target')).submit()
    false
  )
