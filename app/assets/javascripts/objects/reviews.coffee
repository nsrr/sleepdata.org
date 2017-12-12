$(document)
  .on("click", "[data-object~=review-cast-vote]", ->
    disablerWithSpinner($(this))
    params = {}
    params.approved = $(this).data("approved")
    params.comment = $("#agreement_event_comment_new").val()
    $.post($(this).data("path"), params, null, "script")
    false
  )
