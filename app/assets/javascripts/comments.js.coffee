# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document)
  .on('click', '[data-object~="preview-comment"]', () ->
    $.post(root_url + 'forum/' + $(this).data('topic-id') + '/comments/preview', $("#comment_description_#{$(this).data('comment-id')}").serialize() + "&comment_id=" + $(this).data('comment-id'), null, "script")
  )
