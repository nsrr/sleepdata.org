@agreementsReady = () ->
  sig = $('#agreement_signature').val() if $('#agreement_signature').val()
  if $("[data-object~='signature']").length > 0
    $("[data-object~='signature']").signaturePad( drawOnly: true, lineWidth: 0, validateFields: false ).regenerate(sig)
  if $("[data-object~='signature-display']").length > 0
    $("[data-object~='signature-display']").signaturePad( displayOnly: true ).regenerate(sig)
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
