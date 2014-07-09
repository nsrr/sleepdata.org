# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@downloadFile = (index,element) ->
  $("[data-object~='autodownload']")[index].click()

@datasetsReady = () ->
  $("[data-object~='autodownload']").each( (index, element) ->
    setTimeout( (() -> downloadFile(index, element)), 500 )
  )

$(document)
  .on('click', "[data-object~='show-info']", () ->
    $("[data-object~='info-box']").hide()
    $($(this).data("target")).show()
    false
  )
