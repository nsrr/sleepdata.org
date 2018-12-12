$(document)
  .on("change", "#data_request_status", ->
    $("#resubmit-container").hide()
    $("#approval-container").hide()
    $("#data_request_approval_date, #data_request_expiration_date").prop("disabled", true)
    switch $(this).val()
      when "approved"
        $("#approval-container").show()
        $("#data_request_approval_date, #data_request_expiration_date").prop("disabled", false)
        signaturesReady()
      when "resubmit"
        $("#resubmit-container").show()
  )
  .on("click", "[data-object~=select-dataset]", (event) ->
    if event.target.tagName and event.target.tagName.toLowerCase() != "input"
      $($(this).data("target")).prop("checked", !$($(this).data("target")).prop("checked"))

    if $($(this).data("target")).prop("checked")
      $(this).find(".card-header").removeClass("bg-light")
      $(this).find(".card-header").addClass("bg-primary text-white")
      $(this).find("[data-object~=dataset-check-icon]").removeClass("far fa-square")
      $(this).find("[data-object~=dataset-check-icon]").addClass("fas fa-check-square")
    else
      $(this).find(".card-header").removeClass("bg-primary text-white")
      $(this).find(".card-header").addClass("bg-light")
      $(this).find("[data-object~=dataset-check-icon]").removeClass("fas fa-check-square")
      $(this).find("[data-object~=dataset-check-icon]").addClass("far fa-square")
    if $("[name='data_request[dataset_ids][]']:checked").length <= 2
      $(".datasets-warning").hide()
    else
      $(".datasets-warning").show()
  )
  .on('click', "[data-object~=close-data-request]", (event) ->
    return if event.target != this
    $(".data-request-fullscreen-backdrop").removeClass("d-flex")
    $("body").removeClass("noscroll")
    false
  )
  .on('click', "[data-object~=show-data-request]", ->
    $("body").addClass("noscroll")
    $(".data-request-fullscreen-backdrop").addClass("d-flex")
    false
  )
  .on('click', "[data-object~=toggle-data-request-event]", ->
    $(this).find(".data-request-event-icon").toggleClass("data-request-event-icon-rotate")
    $($(this).data("target")).slideToggle()
    false
  )
