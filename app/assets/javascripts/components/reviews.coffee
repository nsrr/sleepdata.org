@reviewsReady = ->
  $("[data-object~=reviewer-autocomplete]").each(->
    $this = $(this)
    $this.textcomplete(
      [
        {
          name: "search"
          match: /(^|\s)@([a-zA-Z0-9]*)$/
          search: (term, callback) ->
            $.getJSON($this.data("url"), { q: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "$1@#{value}"
          cache: true
        }
      ], { appendTo: "body" }
    )
  )
