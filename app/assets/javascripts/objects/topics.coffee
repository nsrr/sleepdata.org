# TODO: Review all methods to see if each is necessary.

@showForumTopicForm = () ->
  $("#forum-top-container").hide()
  $("#new-topic-container").fadeIn('fast')

@hideForumTopicForm = () ->
  $('[name=password]').tooltip('destroy')
  $("#new-topic-container").html('')
  $("#new-topic-container").hide()
  $("#forum-top-container").show()

$(document)
  .on('click', '[data-object~="close-new-forum-topic"]', ->
    hideForumTopicForm()
    false
  )

@showTopicReplyBox = (parent_comment_id, reply_id) ->
  $("#write_comment_#{parent_comment_id}_#{reply_id}").hide()
  $("#comment_container_#{parent_comment_id}_#{reply_id}").fadeIn('fast')

@hideTopicReplyBox = (parent_comment_id, reply_id) ->
  $('[name=password]').tooltip('destroy')
  $("#comment_container_#{parent_comment_id}_#{reply_id}").html('')
  $("#comment_container_#{parent_comment_id}_#{reply_id}").hide()
  $("#write_comment_#{parent_comment_id}_#{reply_id}").show()

@topicsReady = () ->
  if window.location.hash == '#write-a-reply'
    $("#write_comment_root_new a").click()
  else if window.location.hash.substring(1,8) == 'comment'
    $("#{window.location.hash}-container").addClass('highlighted-reply')

$(document)
  .on('click', '[data-object~="toggle-reply"]', () ->
    $(this).closest('.reply-header').siblings('.reply-body,.reply-avatar-container').toggle()
    if $(this).html() == '[-]'
      $(this).html('[+]')
    else
      $(this).html('[-]')
    false
  )
  .on('click', '[data-object~="chapter-no-write-comment"]', () ->
    parent_comment_id = $(this).data('parent-comment-id')
    reply_id = $(this).data('reply-id')
    hideTopicReplyBox(parent_comment_id, reply_id)
    false
  )
  .on('click', '[data-object~="reply-tab"]', () ->
    parent_comment_id = $(this).data('parent-comment-id')
    reply_id = $(this).data('reply-id')
    action = $(this).data('action')
    $("[data-object~='reply-tab'][data-parent-comment-id=#{parent_comment_id}]").removeClass('active')
    $(this).addClass('active')
    $("[data-object~='reply-tab-content'][data-parent-comment-id=#{parent_comment_id}]").hide()
    $("[data-object~='reply-tab-content'][data-parent-comment-id=#{parent_comment_id}][data-action=#{action}]").show()
    false
  )
  .on('click', '[data-object~="reply-tab"][data-action~="preview"]', () ->
    parent_comment_id = $(this).data('parent-comment-id')
    reply_id = $(this).data('reply-id')
    input = "#reply_description_#{parent_comment_id}_#{reply_id}"
    params = {}
    params.reply = { description: $(input).val() }
    params.parent_comment_id = parent_comment_id
    params.reply_id = reply_id
    $.post("#{root_url}replies/preview", params, null, 'script')
    false
  )
  .on('click', '[data-object~="bold-selection"]', () ->
    selection = $($(this).data('target')).getSelection()
    return false unless selection?
    return false if selection.length == 0
    original_text = $($(this).data('target')).val()
    substitute = "**#{selection.text}**"
    new_string = original_text.substring(0, selection.start) + substitute + original_text.substring(selection.end)
    $($(this).data('target')).val(new_string)
    false
  )
  .on('click', '[data-object~="italic-selection"]', () ->
    selection = $($(this).data('target')).getSelection()
    return false unless selection?
    return false if selection.length == 0
    original_text = $($(this).data('target')).val()
    substitute = "*#{selection.text}*"
    new_string = original_text.substring(0, selection.start) + substitute + original_text.substring(selection.end)
    $($(this).data('target')).val(new_string)
    false
  )
  .on('click', '[data-object~="link-selection"]', () ->
    selection = $($(this).data('target')).getSelection()
    return false unless selection?
    original_text = $($(this).data('target')).val()
    substitute = "[#{selection.text}](url)"
    new_string = original_text.substring(0, selection.start) + substitute + original_text.substring(selection.end)
    $($(this).data('target')).val(new_string)
    false
  )
  .on('click', '[data-object~="quote-selection"]', () ->
    selection = $($(this).data('target')).getSelection()
    return false unless selection?
    original_text = $($(this).data('target')).val()
    substitute = "> #{selection.text}"
    new_string = original_text.substring(0, selection.start) + substitute + original_text.substring(selection.end)
    $($(this).data('target')).val(new_string)
    console.log selection
    false
  )
