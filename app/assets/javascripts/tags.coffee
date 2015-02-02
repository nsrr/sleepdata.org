# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@loadColorSelectors = () ->
  $('[data-object~="color-selector"]').each( () ->
    $this = $(this)
    $this.ColorPicker(
      color: $this.data('color')
      onShow: (colpkr) ->
        $(colpkr).fadeIn(500)
        return false
      onHide: (colpkr) ->
        $(colpkr).fadeOut(500)
        $($this.data('form')).submit()
        return false
      onChange: (hsb, hex, rgb) ->
        $($this.data('target')).val('#' + hex)
        $($this.data('target')+"_display").css('backgroundColor', '#' + hex)
      onSubmit: (hsb, hex, rgb, el) ->
        $(el).ColorPickerHide();
    )
  )

@tagsReady = () ->
  loadColorSelectors()

$(document)
  .on('click', '.tag-checkbox', () ->
    if $(this).children().is(':checked')
      $(this).addClass('tag-selected')
    else
      $(this).removeClass('tag-selected')
  )
