
@agreementsReady = () ->
  sig = $('#signature').val() if $('#signature').val()
  $("[data-object~='signature']").signaturePad( drawOnly: true, lineWidth: 0 ).regenerate(sig)
  false
