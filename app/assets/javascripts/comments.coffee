@commentsReady = () ->
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

$(document)
  .on('click', '[data-object~="view-comment-write"]', () ->
    comment_id = $(this).data('comment-id')
    $(this).addClass('active')
    $("[data-object~='view-comment-preview'][data-comment-id=#{comment_id}]").removeClass('active')
    $("[data-object~='view-comment-markup'][data-comment-id=#{comment_id}]").removeClass('active')
    $("#comment_preview_#{comment_id}").hide()
    $("#comment_markup_#{comment_id}").hide()
    $("#comment_write_#{comment_id}").show()
    false
  )
  .on('click', '[data-object~="view-comment-preview"]', () ->
    comment_id = $(this).data('comment-id')
    $.post("#{root_url}forum/#{$(this).data('topic-id')}/comments/preview",
      $("#comment_description_#{comment_id}").serialize() +
      "&comment_id=#{comment_id}", null, 'script')
    $(this).addClass('active')
    $("[data-object~='view-comment-write'][data-comment-id=#{comment_id}]").removeClass('active')
    $("[data-object~='view-comment-markup'][data-comment-id=#{comment_id}]").removeClass('active')
    $("#comment_markup_#{comment_id}").hide()
    $("#comment_write_#{comment_id}").hide()
    $("#comment_preview_#{comment_id}").show()
    false
  )
  .on('click', '[data-object~="view-comment-markup"]', () ->
    comment_id = $(this).data('comment-id')
    $(this).addClass('active')
    $("[data-object~='view-comment-write'][data-comment-id=#{comment_id}]").removeClass('active')
    $("[data-object~='view-comment-preview'][data-comment-id=#{comment_id}]").removeClass('active')
    $("#comment_write_#{comment_id}").hide()
    $("#comment_preview_#{comment_id}").hide()
    $("#comment_markup_#{comment_id}").show()
    false
  )
