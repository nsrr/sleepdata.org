$(document)
  .on('dragenter', '[data-object~="dropfile"]', (e) ->
    $(this).addClass('hover')
    e.stopPropagation()
    e.preventDefault()
  )
  .on('dragleave', '[data-object~="dropfile"]', (e) ->
    $(this).removeClass('hover')
    e.stopPropagation()
    e.preventDefault()
  )
  .on('dragover', '[data-object~="dropfile"]', (e) ->
    e.stopPropagation()
    e.preventDefault()
  )
  .on('drop', '[data-object~="dropfile"]', (e) ->
    $(this).removeClass('hover')
    e.stopPropagation()
    e.preventDefault()

    event = e.originalEvent || e
    data = new FormData()
    $.each(event.dataTransfer.files, (index, file) ->
      data.append 'images[]', file
    )

    file_count = event.dataTransfer.files.length

    if file_count == 1
      plural = ''
    else
      plural = 's'

    $this = $(this)
    $($this.data('log-id')).html("Uploading #{file_count} file#{plural}...")
    $.ajax(
      url: $this.data('upload-url')
      type: 'POST'
      data: data         # The form with the file inputs.
      processData: false # Using FormData, no need to process data.
      contentType: false
    ).done( () ->
      $($this.data('log-id')).html('Success: Images uploaded!')
    ).fail( () ->
      url = $this.data('fallback-url')
      $($this.data('log-id')).html("An error occurred, the images could not be uploaded! Please try again or <a href=\"#{$this.data('fallback-url')}\">upload the images</a> manually.")
    )
  )
