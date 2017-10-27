$(document)
  .on('click', '[data-object~="view-agreement-event-preview"]', () ->
    agreement_event_id = $(this).data('agreement-event-id')
    $.post("#{root_url}agreements/#{$(this).data('agreement-id')}/events/preview",
      $("#agreement_event_comment_#{agreement_event_id}").serialize() +
      "&agreement_event_id=#{agreement_event_id}", null, 'script')
    false
  )
  .on('click', '[data-object~="view-agreement-event"]', () ->
    agreement_event_id = $(this).data('agreement-event-id')
    $("[data-object~='view-agreement-event'][data-agreement-event-id=#{agreement_event_id}]").removeClass('active')
    $(this).addClass('active')
    $("#agreement_event_write_#{agreement_event_id}").hide()
    $("#agreement_event_preview_#{agreement_event_id}").hide()
    $("#agreement_event_vote_#{agreement_event_id}").hide()
    $("#agreement_event_tags_#{agreement_event_id}").hide()
    $("#agreement_event_review_#{agreement_event_id}").hide()
    $("#agreement_event_markup_#{agreement_event_id}").hide()
    $("#agreement_event_datasets_#{agreement_event_id}").hide()
    $("#agreement_event_#{$(this).data('action')}_#{agreement_event_id}").show()
    signaturesReady()
    false
  )

