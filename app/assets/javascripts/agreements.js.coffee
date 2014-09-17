@agreementsReady = () ->
  sig = $('#agreement_signature').val() if $('#agreement_signature').val()
  if $("[data-object~='signature']").length > 0
    $("[data-object~='signature']").signaturePad( drawOnly: true, lineWidth: 0, validateFields: false ).regenerate(sig)
  false

$(document)
  .on('click', "[data-object~='select_radio_button']", () ->
    $($(this).data('target')).prop('checked', true)
  )
  .on('click', '[data-object~="submit-draft"]', () ->
    $("#step").val('0')
    $("#agreement_step").val('0')
    $($(this).data('target')).submit()
    false
  )

