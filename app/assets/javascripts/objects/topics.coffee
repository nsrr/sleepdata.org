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

@topicsReady = () ->
  if window.location.hash == '#write-a-reply'
    $("#write_reply_root_new a").click()
  else if window.location.hash.substring(1,8) == 'comment'
    $("#{window.location.hash}-container").addClass('highlighted-reply')
