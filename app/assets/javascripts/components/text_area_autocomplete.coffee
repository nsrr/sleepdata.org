@textAreaAutocompleteReady = ->
  $('[data-object~="text-area-autocomplete"]').textcomplete(
    [
      mentions: $('[data-object~="text-area-autocomplete"]').data('mentions')
      match: /\B@(\w*)$/i
      search: (term, callback) ->
        callback($.map(this.mentions, (mention) ->
          if mention.toLowerCase().indexOf(term.toLowerCase()) == 0
            return mention
          else
            return null
        ))
      index: 1
      replace: (mention) ->
        return "@#{mention} "
    ], { appendTo: 'body' }
  )
