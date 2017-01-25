@fadeAndRemove = (element) ->
  $(element).fadeOut(500, -> $(element).remove())

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

# TODO: Might be able to remove this in the future with Turbolinks 5
# https://github.com/turbolinks/turbolinks-classic/issues/455
@fix_ie10_placeholder = ->
  $('textarea').each ->
    if $(@).val() == $(@).attr('placeholder')
      $(@).val ''

@componentsReady = ->
  affixReady()
  graphsReady()
  textAreaAutocompleteReady()

@extensionsReady = ->
  clipboardReady()
  datepickerReady()
  fileDragReady()
  notouchReady()
  tooltipsReady()
  turbolinksReady()
  typeaheadReady()

@objectsReady = ->
  agreementsReady()
  challengesReady()
  datasetsReady()
  filesReady()
  repliesReady()
  tagsReady()
  variablesReady()

@ready = ->
  setFocusToField("#collection_form #s, #search, #s") if $("#collection_form #s, #search, #s").val() != ''
  window.$isDirty = false
  fix_ie10_placeholder()
  componentsReady()
  extensionsReady()
  objectsReady()

$(window).onbeforeunload = -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(ready)
$(document)
  .on('turbolinks:load', ready)
  .on('turbolinks:click', -> confirm("You haven't saved your changes.") if window.$isDirty)
  .on('click', '[data-object~="suppress-click"]', () ->
    false
  )
  .on('click', '[data-object~="submit"]', () ->
    window.$isDirty = false
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="submit-and-disable"]', ->
    window.$isDirty = false
    $(this).prop('disabled', true)
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="hide-target"]', () ->
    $($(this).data('target')).hide()
    false
  )
  .on('click', '[data-object~="show-target"]', () ->
    $($(this).data('target')).show()
    false
  )
  .on('click', '[data-object~="toggle-delete-buttons"]', () ->
    $($(this).data('target-show')).show()
    $($(this).data('target-hide')).hide()
    false
  )
  .on('click', '[data-object~="toggle-visibility"]', ->
    $($(this).data('target')).toggle()
    false
  )
