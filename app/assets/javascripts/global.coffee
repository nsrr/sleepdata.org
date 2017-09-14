@fadeAndRemove = (element) ->
  $(element).fadeOut(500, -> $(element).remove())

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@componentsReady = ->
  expandableInputReady()
  graphsReady()
  lettersReady()
  textAreaAutocompleteReady()

@extensionsReady = ->
  clipboardReady()
  datepickerReady()
  fileDragReady()
  notouchReady() # TODO: Remove, replace with scss for @media (hover) queries
  signaturesReady()
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

@turbolinksReady = ->
  setFocusToField("#search, #s") if $("#search, #s").val() != ''
  window.$isDirty = false
  componentsReady()
  extensionsReady()
  objectsReady()

# These functions only get called on the initial page visit (no turbolinks).
# Browsers that don't support turbolinks will initialize all functions in
# turbolinks on page load. Those that do support Turbolinks won't call these
# methods here, but instead will wait for `turbolinks:load` event to prevent
# running the functions twice.
@initialLoadReady = ->
  turbolinksReady() unless Turbolinks.supported

$(window).onbeforeunload = -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(initialLoadReady)
$(document)
  .on('turbolinks:load', turbolinksReady)
  .on('turbolinks:before-visit', (event) ->
    event.preventDefault() if window.$isDirty and !confirm("You haven't saved your changes.")
  )
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
