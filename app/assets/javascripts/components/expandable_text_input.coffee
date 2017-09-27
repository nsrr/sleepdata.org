@setInputSize = (element) ->
  $(element).removeClass("input-success input-highlight")
  $widthTest = getWidthTestElement()
  if ($(element).hasClass("signature-pad-body") && window.$signaturePad? && !window.$signaturePad.isEmpty()) || ($(element).is(":checkbox") && $(element).is(":checked")) || !$(element).is(":checkbox") && $(element).val().length > 0
    $widthTest.text($(element).val())
    $(element).addClass("input-success")
  else
    $widthTest.text($(element).prop("placeholder"))
    $(element).addClass("input-highlight")
  standard_width = 3
  standard_width += 6 if $(element).hasClass("form-control-inline")
  standard_width += 20 if $(element).hasClass("form-control")
  $(element).css("width", $widthTest.width() + standard_width) unless $(element).hasClass("signature-pad-body")
  resetHelpTexts()

@resetHelpText = (element) ->
  $help_element = $("##{$(element).data("help-element")}_help_text")
  $help_element.removeClass("agreement-helper-success agreement-helper-highlight")
  if ($(element).hasClass("signature-pad-body") && window.$signaturePad? && !window.$signaturePad.isEmpty()) || ($(element).is(":checkbox") && $(element).is(":checked")) || !$(element).is(":checkbox") && $(element).val().length > 0
    $help_element.html('<i class="fa fa-caret-left"></i> ' + $(element).data("help-text") + ' <i class="fa fa-check-square-o"></i>')
    $help_element.addClass("agreement-helper-success")
  else
    $help_element.html('<i class="fa fa-caret-left"></i> ' + $(element).data("help-text")) #  + ' <i class="fa fa-square-o"></i>'
    $help_element.addClass("agreement-helper-highlight")
  offset = $("#top-menu").height()
  offset = offset - ($(element).height() / 2) if $(element).hasClass("signature-pad-body")
  $help_element.css("top", $(element).offset().top - offset)
  $help_element.fadeIn()

@agreementHelpers = ->
  $drawer = $("#agreement-helper-drawer")
  return if $drawer.length == 0
  $('[data-help-element]').each((index, element) ->
    $label = $("<label>"
      "id": "#{$(this).data("help-element")}_help_text"
      "class": "agreement-helper"
      "for": $(this).data("help-element") unless $(this).is(":checkbox")
    )
    $drawer.append($label)
  )
  resetHelpTexts()

@resetHelpTexts = ->
  $('[data-object~="text-input-expandable"]').each(->
    resetHelpText($(this))
  )

@expandableInputReady = ->
  $('[data-object~="text-input-expandable"]').each(->
    setInputSize($(this))
  )
  agreementHelpers()

@getWidthTestElement = ->
  if $("#width-test").length > 0
    $widthTest = $("#width-test")
  else
    $widthTest = $("<div>"
      "id": "width-test"
      "class": "width-test"
    )
    $("body").prepend($widthTest)
    $widthTest = $("#width-test")
  return $widthTest

$(window).resize(-> resetHelpTexts())

$(document)
  .on("change", '[data-object~="text-input-expandable"]', ->
    setInputSize($(this))
  )
