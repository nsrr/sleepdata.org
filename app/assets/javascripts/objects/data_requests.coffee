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
