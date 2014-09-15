
@agreementsReady = () ->
  sig = $('#signature').val() if $('#signature').val()
  if $("[data-object~='signature']").length > 0
    $("[data-object~='signature']").signaturePad( drawOnly: true, lineWidth: 0 ).regenerate(sig)
  false
