@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@initializeTypeahead = () ->
  $('[data-object~="typeahead"]').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

# TODO: Might be able to remove this in the future with Turbolinks 5
# https://github.com/turbolinks/turbolinks-classic/issues/455
@fix_ie10_placeholder = ->
  $('textarea').each ->
    if $(@).val() == $(@).attr('placeholder')
      $(@).val ''

@initializeTurbolinks = () ->
  # Don't cache pages with Turbolinks
  Turbolinks.pagesCached(0)
  Turbolinks.allowLinkExtensions('md')

@ready = () ->
  contourReady()
  $("[rel=tooltip]").tooltip( trigger: 'hover' )
  if $("#collection_form #s, #page_name, #search_form #s, #search, #collection_form #s, #s").val() != ''
    setFocusToField("#collection_form #s, #page_name, #search_form #s, #search, #collection_form #s, #s")
  initializeTurbolinks()
  window.$isDirty = false
  variablesReady()
  datasetsReady()
  agreementsReady()
  commentsReady()
  tagsReady()
  graphsReady()
  mapsReady()
  challengesReady()
  initializeTypeahead()
  affixReady()
  fileDragReady()
  new WOW().init()
  fix_ie10_placeholder()

$(window).onbeforeunload = () -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('page:before-change', -> confirm("You haven't saved your changes.") if window.$isDirty)
  .on('click', '[data-object~="submit"]', () ->
    window.$isDirty = false
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="list-submit"]', () ->
    $('#view').val('list')
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="grid-submit"]', () ->
    $('#view').val('')
    $($(this).data('target')).submit()
    false
  )
  .on('click', "[data-basename]", () ->
    $.get(root_url + 'collection_modal', { "basename": $(this).data('basename'), slug: $(this).data('slug'), d: $(this).data('d') }, null, "script")
    return false
  )
  .on('click', '[data-object~="hide-target"]', () ->
    $($(this).data('target')).hide()
    false
  )
  .on('click', '[data-object~="show-target"]', () ->
    $($(this).data('target')).show()
    false
  )
  .on('click', '[data-object~="disable-target"]', () ->
    $($(this).data('input-target')).prop('disabled', true);
  )
  .on('click', '[data-object~="enable-target"]', () ->
    $($(this).data('input-target')).prop('disabled', false);
  )
  .on('click', '[data-object~="agreement-update"]', () ->
    $("#email-comments-container").hide()
    $("#approval-date-container, #expiration-date-container").show()
    $("#agreement_approval_date, #agreement_expiration_date").prop('disabled', false);
  )
  .on('click', '[data-object~="agreement-resubmit"]', () ->
    $("#email-comments-container").show()
    $("#approval-date-container, #expiration-date-container").hide()
    $("#agreement_approval_date, #agreement_expiration_date").prop('disabled', true);
  )
  .on('click', '[data-object~="toggle-delete-buttons"]', () ->
    $($(this).data('target-show')).show()
    $($(this).data('target-hide')).hide()
    false
  )
