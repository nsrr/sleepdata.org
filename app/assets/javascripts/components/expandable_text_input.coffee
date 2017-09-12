@setInputSize = (element) ->
  $(element).removeClass("input-success input-highlight")
  if ($(element).is(":checkbox") && $(element).is(":checked")) || !$(element).is(":checkbox") && $(element).val().length > 0
    $("#width-test").text($(element).val())
    $(element).addClass("input-success")
  else
    $("#width-test").text($(element).prop("placeholder"))
    $(element).addClass("input-highlight")
  standard_width = 3
  standard_width += 20 if $(element).hasClass("form-control")
  $(element).css("width", $("#width-test").width() + standard_width)
  resetHelpTexts()

@resetHelpText = (element) ->
  help_element = $("##{$(element).data("help-element")}_help_text")
  help_element.removeClass("agreement-helper-success agreement-helper-highlight")
  if ($(element).is(":checkbox") && $(element).is(":checked")) || !$(element).is(":checkbox") && $(element).val().length > 0
    help_element.html('<i class="fa fa-caret-left"></i> ' + $(element).data("help-text") + ' <i class="fa fa-check-square-o"></i>')
    help_element.addClass("agreement-helper-success")
  else
    help_element.html('<i class="fa fa-caret-left"></i> ' + $(element).data("help-text")) #  + ' <i class="fa fa-square-o"></i>'
    help_element.addClass("agreement-helper-highlight")
  help_element.css("top", $(element).offset().top - 56)
  help_element.fadeIn()

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

$(window).resize(-> resetHelpTexts())

$(document)
  .on("change", '[data-object~="text-input-expandable"]', ->
    setInputSize($(this))
  )
