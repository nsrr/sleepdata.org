@addOrRemove = (array, value) ->
  index = array.indexOf(value)
  if index == -1
    array.push(value)
  else
    array.splice(index, 1)
  array

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

@getTagIds = ->
  if $("#data_request_tag_ids").val().length == 0
    ["0"]
  else
    ["0"].concat($("#data_request_tag_ids").val().split(",")).unique()

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
    $("#agreement_event_review_#{agreement_event_id}").hide()
    $("#agreement_event_datasets_#{agreement_event_id}").hide()
    $("#agreement_event_#{$(this).data('action')}_#{agreement_event_id}").show()
    signaturesReady()
    false
  )
  .on("click", "[data-object~=toggle-tag]", ->
    tag_ids = addOrRemove(getTagIds(), "#{$(this).data("tag-id")}")
    $(this).find("i").toggleClass("fas fa-check-square far fa-square tag-unselected")
    $("#data_request_tag_ids").val(tag_ids.join(","))
    false
  )
  .on("hide.bs.dropdown", "#agreement-event-tags-dropdown", ->
    tag_ids = getTagIds().sort()
    orig_tag_ids = $(this).data("orig-tag-ids").sort()
    return if (tag_ids.length is orig_tag_ids.length and tag_ids.every (elem, i) -> elem is orig_tag_ids[i])
    params = {}
    params.data_request = { tag_ids: tag_ids }
    $.post($(this).data("path"), params, null, "script")
  )
