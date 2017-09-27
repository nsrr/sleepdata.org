# TODO: Remove all of this?

$(document)
  .on('click', '[data-object~="select_checkbox_panel"]', (event) ->
    # TODO: Remove this method
    if event.target.tagName and event.target.tagName.toLowerCase() != 'input'
      $($(this).data('target')).prop('checked', !$($(this).data('target')).prop('checked'))

    if $($(this).data('target')).prop('checked')
      $(this).closest('.panel').removeClass('panel-default')
      $(this).closest('.panel').addClass('panel-success')
    else
      $(this).closest('.panel').removeClass('panel-success')
      $(this).closest('.panel').addClass('panel-default')
    if $('[name="agreement[dataset_ids][]"]:checked').length < 2
      $('#too-many-datasets').hide()
    else
      $('#too-many-datasets').show()
  )
  .on('click', '[data-object~="submit-draft"]', ->
    # TODO: Remove (rewrite) this method
    window.$isDirty = false
    $('#agreement_draft_mode').val('1')
    $($(this).data('target')).submit()
    false
  )
  .on('change', ':input', ->
    # TODO: Potentially remove this
    if $('#isdirty').val() == '1'
      window.$isDirty = true
  )
  .on('change', '#agreement_status', ->
    $('#resubmit-container').hide()
    $('#approval-container').hide()
    $('#agreement_approval_date, #agreement_expiration_date').prop('disabled', true)
    switch $(this).val()
      when 'approved'
        $('#approval-container').show()
        $('#agreement_approval_date, #agreement_expiration_date').prop('disabled', false)
      when 'resubmit'
        $('#resubmit-container').show()
  )
