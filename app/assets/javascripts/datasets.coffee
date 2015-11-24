# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# @initializeDatasetNavigationBar = () ->
#   $("[data-object~='dataset-affix']").each( (index, element) ->
#     $(element).affix(
#       offset:
#         top: 200
#         bottom: 0
#     )
#   )


@downloadFile = (index,element) ->
  $("[data-object~='autodownload']")[index].click()

@datasetsReady = () ->
  $("[data-object~='autodownload']").each( (index, element) ->
    setTimeout( (() -> downloadFile(index, element)), 500 )
  )
  # @initializeDatasetNavigationBar()

$(document)
  .on('click', "[data-object~='show-info']", () ->
    $("[data-object~='info-box']").hide()
    $($(this).data("target")).show()
    false
  )
  .on('click', "[data-object~='set-flag']", () ->
    $("[data-flag~='#{$(this).data('flag')}']").removeClass('active')
    $("[data-flag~='#{$(this).data('flag')}']").removeClass('btn-primary')
    $("[data-flag~='#{$(this).data('flag')}']").addClass('btn-default')
    $("[data-flag-type~='#{$(this).data('flag')}']").hide()

    $("##{$(this).data('flag')}-flag").html($(this).data('value'))
    $(this).addClass('active')
    $(this).addClass('btn-primary')
    $("[data-flag-type='#{$(this).data('flag')}'][data-flag-value='#{$(this).data('value')}']").show()
    false
  )
  .on('click', "[data-object~='toggle-page-list']", () ->
    $(".page-list-container").toggle()
    $("#show-page-button").toggle()
    $("#documentation-content").toggleClass("col-sm-12 col-sm-9")
    $("#sidebar-content").toggleClass("col-sm-3")
    false
  )
