$(document)
  .on('click', '[data-object~="preview-review"]', () ->
    $.post("#{root_url}reviews/#{$(this).data('agreement-id')}/preview",
      $("#agreement_event_comment_#{$(this).data('review-id')}").serialize() +
      "&review_id=#{$(this).data('review-id')}", null, 'script')
  )
