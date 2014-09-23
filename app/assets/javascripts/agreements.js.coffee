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
    if $($(this).data('target')).prop('checked')
      $($(this).data('target')).prop('checked', false)
      $(this).closest(".panel").removeClass('panel-success')
      $(this).closest(".panel").addClass('panel-default')
    else
      $($(this).data('target')).prop('checked', true)
      $(this).closest(".panel").removeClass('panel-default')
      $(this).closest(".panel").addClass('panel-success')
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
