@prepareVariableEditing = ->
  $(".container").toggleClass("container container-fluid")
  $("#legal-document-variable").removeClass("d-none")

@breakdownVariableEditing = ->
  $("#legal-document-variable").html("")
  $("#legal-document-variable").addClass("d-none")
  $(".container-fluid").toggleClass("container container-fluid")

@scrollToVariableEditLink = (legal_document_variable_id) ->
  $reference_element = $("#legal-document-variable-#{legal_document_variable_id}-link")
  scrollToElementCenter($reference_element)

@setVariableEditTop = (legal_document_variable_id) ->
  $reference_element = $("#legal-document-variable-#{legal_document_variable_id}-link")
  $variable_edit_box = $("#legal-document-variable-#{legal_document_variable_id}-container")
  $variable_edit_box.css("top", $reference_element.offset().top - $("#legal-document-variable").offset().top)
  $variable_edit_box.fadeIn()
  scrollToElementCenter($variable_edit_box)

@scrollToElementCenter = (element) ->
  offset = computeCenterOffset($(element))
  scrollToOffset(offset)

@computeCenterOffset = (element) ->
  elOffset = $(element).offset().top
  elHeight = $(element).height()
  windowHeight = $(window).height()
  if elHeight < windowHeight
    elOffset - ((windowHeight / 2) - (elHeight / 2))
  else
    elOffset - $("#top-menu").height() - 30

@scrollToOffset = (offset) ->
  $('html, body').animate { scrollTop: offset }, 400

@recenterVariableContainer = ->
  $variable_edit_box = $(".legal-document-variable-container")
  if $variable_edit_box.length > 0
    $reference_element = $("#legal-document-variable-#{$variable_edit_box.data("legal-document-variable-id")}-link")
    $variable_edit_box.css("top", $reference_element.offset().top - $("#legal-document-variable").offset().top)

$(window).resize(-> recenterVariableContainer())
