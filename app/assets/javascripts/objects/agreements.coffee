# TODO: Remove all of this?

$(document)
  .on('click', '[data-object~="select-dataset"]', (event) ->
    # TODO: Remove this method
    if event.target.tagName and event.target.tagName.toLowerCase() != 'input'
      $($(this).data('target')).prop('checked', !$($(this).data('target')).prop('checked'))

    if $($(this).data('target')).prop('checked')
      $(this).find('.card-header').removeClass('bg-light')
      $(this).find('.card-header').addClass('bg-primary text-white')
      $(this).find("[data-object~=dataset-check-icon]").removeClass("fa-square-o")
      $(this).find("[data-object~=dataset-check-icon]").addClass("fa-check-square-o")
    else
      $(this).find('.card-header').removeClass('bg-primary text-white')
      $(this).find('.card-header').addClass('bg-light')
      $(this).find("[data-object~=dataset-check-icon]").removeClass("fa-check-square-o")
      $(this).find("[data-object~=dataset-check-icon]").addClass("fa-square-o")
    if $('[name="data_requests[dataset_ids][]"]:checked').length < 2
      $('#too-many-datasets').hide()
    else
      $('#too-many-datasets').show()
  )
  .on('change', ':input', ->
    # TODO: Potentially remove this
    if $('#isdirty').val() == '1'
      window.$isDirty = true
  )
