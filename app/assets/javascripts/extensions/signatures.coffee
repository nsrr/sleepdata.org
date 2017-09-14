@signaturesReady = ->
  wrapper = document.getElementById('signature-pad')
  return unless wrapper?
  clearButton = wrapper.querySelector('[data-action=clear]')
  savePNGButton = wrapper.querySelector('[data-action=save-png]')
  saveSVGButton = wrapper.querySelector('[data-action=save-svg]')
  window.$canvas = wrapper.querySelector('canvas')
  resizeCanvas()
  window.$signaturePad = undefined
  window.$signaturePad = new SignaturePad(window.$canvas, minDistance: 0)
  if clearButton?
    clearButton.addEventListener 'click', (event) ->
      window.$signaturePad.clear()
      event.stopPropagation()
      event.preventDefault()
      return
  if savePNGButton?
    savePNGButton.addEventListener 'click', (event) ->
      if window.$signaturePad.isEmpty()
        alert 'Please provide signature first.'
      else
        window.open window.$signaturePad.toDataURL()
      return
  if saveSVGButton?
    saveSVGButton.addEventListener 'click', (event) ->
      if window.$signaturePad.isEmpty()
        alert 'Please provide signature first.'
      else
        window.open window.$signaturePad.toDataURL('image/svg+xml')
      return

# Adjust canvas coordinate space taking into account pixel ratio,
# to make it look crisp on mobile devices.
# This also causes canvas to be cleared.
@resizeCanvas = ->
  # When zoomed out to less than 100%, for some very strange reason,
  # some browsers report devicePixelRatio as less than 1
  # and only part of the canvas is cleared then.
  return unless window.$canvas?
  ratio = Math.max(window.devicePixelRatio or 1, 1)
  window.$canvas.width = window.$canvas.offsetWidth * ratio
  window.$canvas.height = window.$canvas.offsetHeight * ratio
  window.$canvas.getContext('2d').scale ratio, ratio
  return

$(window).resize(-> resizeCanvas())

$(document)
  .on('click', '[data-object~="submit-signature"]', ->
    if window.$signaturePad.isEmpty()
      alert 'Please provide signature first.'
    else
      $("#data_uri").val(window.$signaturePad.toDataURL())
      $($(this).data("target")).submit()
    false
  )
