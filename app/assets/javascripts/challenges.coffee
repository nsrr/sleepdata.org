# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


@challengesReady = () ->
  # $('#affix-container').height($("#affix-img").height())
  $("[data-object~='signal-affix']").each( (index, element) ->
    $(element).affix(
      offset:
        top: $(element).offset().top - 51
    )
  )
