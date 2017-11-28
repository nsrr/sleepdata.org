@progressReady = ->
  if $("[data-object~=ajax-timer]").length > 0
    $.each($("[data-object~=ajax-timer]"), ->
      $this = $(this)
      interval = setInterval( ->
        $.post($this.data("path"), "interval=#{interval}", null, "script")
      , 1000)
    )
