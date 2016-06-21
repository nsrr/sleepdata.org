@showForumTopicForm = ->
  $("#forum-top-container").hide()
  $("#new-topic-container").fadeIn('fast')

@hideForumTopicForm = ->
  $('[name=password]').tooltip('destroy')
  $("#new-topic-container").html('')
  $("#new-topic-container").hide()
  $("#forum-top-container").show()

$(document)
  .on('click', '[data-object~="close-new-forum-topic"]', ->
    hideForumTopicForm()
    false
  )
