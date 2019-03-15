@fadeAndRemove = (element) ->
  $(element).fadeOut(500, -> $(element).remove())

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@componentsReady = ->
  chartsReady()
  expandableInputReady()
  graphsReady()
  progressReady()
  reportsReady()
  reviewsReady()

@extensionsReady = ->
  clipboardReady()
  datepickerReady()
  fileDragReady()
  signaturesReady()
  tooltipsReady()

@objectsReady = ->
  datasetsReady()
  filesReady()
  repliesReady()
  tagsReady()
  variablesReady()

@turbolinksReady = ->
  setFocusToField("#search, #s") if $("#search, #s").val() != ''
  componentsReady()
  extensionsReady()
  objectsReady()

@submitTarget = (element) ->
  $(element).data("target").submit()
  # $target = $($(element).data("target"))[0]
  # Rails.fire($target, "submit")

# These functions only get called on the initial page visit (no turbolinks).
# Browsers that don't support turbolinks will initialize all functions in
# turbolinks on page load. Those that do support Turbolinks won't call these
# methods here, but instead will wait for `turbolinks:load` event to prevent
# running the functions twice.
@initialLoadReady = ->
  turbolinksReady() unless Turbolinks.supported

$(document).ready(initialLoadReady)
$(document)
  .on('turbolinks:load', turbolinksReady)
  .on('click', '[data-object~="suppress-click"]', ->
    false
  )
  .on("click", "[data-object~=submit]", ->
    # submitTarget($(this))
    $($(this).data("target")).submit()
    false
  )
  .on("click", "[data-object~=submit-js-and-disable]", ->
    disablerWithSpinner($(this))
    target = $($(this).data("target"))[0]
    Rails.fire(target, "submit")
    false
  )
  .on('click', '[data-object~="submit-and-disable"]', ->
    disablerWithSpinner($(this))
    # submitTarget($(this))
    $($(this).data("target")).submit()
    false
  )
  .on('click', '[data-object~="submit-draft-and-disable"]', ->
    disablerWithSpinner($(this))
    $('#data_request_draft').val('1')
    # submitTarget($(this))
    $($(this).data("target")).submit()
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
