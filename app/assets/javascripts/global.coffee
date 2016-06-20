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
  Turbolinks.enableProgressBar()

@initializeClipboard = () ->
  clipboard = new Clipboard('[data-clipboard-target],[data-clipboard-text]')
  clipboard.on('success', (e) ->
    $(e.trigger).tooltip('show')
    setTimeout(
      () -> $(e.trigger).tooltip('destroy'),
      1000
    )
    e.clearSelection()
  )

@loadDatepicker = ->
  $('.datepicker').datepicker('remove')
  $('.datepicker').datepicker(autoclose: true)

# TODO: Remove unused ready methods
@ready = () ->
  $("[rel=tooltip]").tooltip(trigger: 'hover')
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
  initializeClipboard()
  initializeFiles()
  loadDatepicker()
  repliesReady()

$(window).onbeforeunload = () -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('page:before-change', -> confirm("You haven't saved your changes.") if window.$isDirty)
  .on('click', '[data-object~="suppress-click"]', () ->
    false
  )
  .on('click', '[data-object~="submit"]', () ->
    window.$isDirty = false
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
  .on('click', '[data-object~="disable-target"]', () ->
    $($(this).data('input-target')).prop('disabled', true);
  )
  .on('click', '[data-object~="enable-target"]', () ->
    $($(this).data('input-target')).prop('disabled', false);
  )
  .on('click', '[data-object~="toggle-delete-buttons"]', () ->
    $($(this).data('target-show')).show()
    $($(this).data('target-hide')).hide()
    false
  )
