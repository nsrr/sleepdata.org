@setContinueButtonText = (text) ->
  $("#continue-btn").html("#{text} <i class=\"fas fa-caret-right\"></i>")

@resetUploadContainerText = ->
  $upload = $("#upload")
  $percent = $("#percent")
  $process = $("#process")
  $upload.html("Drag files (PDFs) here to attach to data request or <a href=\"#{$("#supporting-documents-upload").data("fallback-url")}\">click here</a> to upload documents.")
  $percent.html("")
  $process.html("")


$(document)
  .on('dragenter', '[data-object~="supporting-documents-dropfile"]', (e) ->
    $(this).addClass('upload-hover')
    e.stopPropagation()
    e.preventDefault()
  )
  .on('dragleave', '[data-object~="supporting-documents-dropfile"]', (e) ->
    relatedTarget = e.relatedTarget || e.toElement
    if $(relatedTarget).closest('[data-object~="supporting-documents-dropfile"]').length == 0
      $(this).removeClass('upload-hover')
    e.stopPropagation()
    e.preventDefault()
  )
  .on('dragover', '[data-object~="supporting-documents-dropfile"]', (e) ->
    e.stopPropagation()
    e.preventDefault()
  )
  .on('drop', '[data-object~="supporting-documents-dropfile"]', (e) ->
    $(this).removeClass('upload-hover')
    e.stopPropagation()
    e.preventDefault()

    event = e.originalEvent || e
    data = new FormData()
    $.each(event.dataTransfer.files, (index, file) ->
      data.append 'documents[]', file
    )

    file_count = event.dataTransfer.files.length

    if file_count == 1
      plural = ''
    else
      plural = 's'

    $this = $(this)
    $uploadContainer = $("#supporting-documents-upload")
    $percentbar = $("#upload-bar")
    $upload = $("#upload")
    $percent = $("#percent")
    $process = $("#process")

    $uploadContainer.addClass("upload-started")
    $percentbar.css("width", "0%")
    $percentbar.removeClass("upload-success upload-failure")
    $upload.html("Uploading")
    $percent.html("")
    $process.html("")

    $.ajax(
      url: $this.data('upload-url')
      type: 'POST'
      data: data         # The form with the file inputs.
      processData: false # Using FormData, no need to process data.
      contentType: false
      xhr: ->
        myXhr = $.ajaxSettings.xhr()
        if myXhr.upload
          myXhr.upload.addEventListener('progress', (e) ->
            if e.lengthComputable
              done = e.loaded
              total = e.total
              calculated_percent = Math.round(done / total * 100)
              if done == total
                $percentbar.css("width", "100%")
                $upload.html("<i class=\"fas fa-check-square text-success\"/> <span class=\"text-muted\">Upload complete.</span>")
                $percent.html("")
                $process.html("<i class=\"fas fa-spinner fa-spin\"/> Processing...")
              else
                $percentbar.css("width", "#{calculated_percent}%")
                $upload.html("Uploading")
                $percent.html("#{calculated_percent}%...")
          )
        myXhr
    ).done(->
      $percentbar.addClass("upload-success")
      $process.html("<i class=\"fas fa-check-square text-success\"/> <span class=\"text-muted\">Processing complete.</span><br>#{file_count} file#{plural} uploaded. Add more files?")
      $uploadContainer.removeClass("upload-started")
      setContinueButtonText("Continue")
    ).fail( (jqXHR, textStatus, errorThrown) ->
      url = $this.data('fallback-url')
      $percentbar.addClass("upload-failure")
      $upload.html("<span class=\"text-danger\"><i class=\"fas fa-times\"/> Upload failed: <small>#{errorThrown}</small></span>")
      $percent.html("")
      $process.html("Please try again or <a href=\"#{url}\">upload the documents</a> manually.")
      $uploadContainer.removeClass("upload-started")
    )
  )



