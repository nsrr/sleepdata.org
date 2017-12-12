$(document)
  .on("click", "[data-object~=review-cast-vote]", ->
    disablerWithSpinner($(this))
    params = {}
    params.approved = $(this).data("approved")
    $.post($(this).data("path"), params, null, "script")
    false
  )
