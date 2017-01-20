@notouchReady = ->
  $('body').addClass('no-touch') if (document.documentElement.ontouchstart == undefined)
