@challengesReady = ->
  # $('#affix-container').height($("#affix-img").height())
  affix_height = 30
  border_adjustment = 1
  $('[data-object~="signal-affix"]').each( (index, element) ->
    $(element).affix(
      offset:
        # top: $(element).offset().top - 51
        # 78px + 31 = 109
        top: () ->
          $('.challenge-header').outerHeight(true) +
          $('.flash-alert').outerHeight(true) +
          $('.flash-notice').outerHeight(true) +
          affix_height + border_adjustment
        bottom: 0
    )
  )
