@agreementsReady = () ->
  $("[data-object~='signature']").each( (index, element) ->
    sig = $($(this).data('signature-target')).val() if $($(this).data('signature-target')).val()
    $(this).signaturePad( drawOnly: true, lineWidth: 0, validateFields: false, output: $(this).data('signature-target') ).regenerate(sig)
  )
  $("[data-object~='signature-display']").each( (index, element) ->
    sig = $($(this).data('signature-target')).val() if $($(this).data('signature-target')).val()
    $(this).signaturePad( displayOnly: true, output: $(this).data('signature-target') ).regenerate(sig)
  )
  false

$(document)
  .on('click', "[data-object~='select_radio_button']", () ->
    $($(this).data('target')).prop('checked', true)
  )
  .on('click', "[data-object~='select_checkbox_panel']", (evt) ->
    if event.target.tagName and event.target.tagName.toLowerCase() != 'input'
      $($(this).data('target')).prop('checked', !$($(this).data('target')).prop('checked'))

    if $($(this).data('target')).prop('checked')
      $(this).closest(".panel").removeClass('panel-default')
      $(this).closest(".panel").addClass('panel-success')
    else
      $(this).closest(".panel").removeClass('panel-success')
      $(this).closest(".panel").addClass('panel-default')
    if $("[name='agreement[dataset_ids][]']:checked").length < 2
      $('#too-many-datasets').hide()
    else
      $('#too-many-datasets').show()
  )
  .on('click', '[data-object~="submit-draft"]', () ->
    window.$isDirty = false
    $("#agreement_draft_mode").val('1')
    $($(this).data('target')).submit()
    false
  )
  .on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )
