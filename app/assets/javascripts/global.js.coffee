@ready = () ->
  $('[data-object~="form-load"]').submit()

$(document).ready(ready)
$(document).on('page:load', ready)
