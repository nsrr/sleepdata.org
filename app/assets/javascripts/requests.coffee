$(document)
  .on('click', "[data-object~='toggle-sign-up']", () ->
    if $("#sign-up-form").is(':visible')
      $("#sign-up-form").toggle()
      $("#sign-in-form").toggle('fade')
      $("#sign-up-sign-in-button").html('Sign in <span class="glyphicon glyphicon-arrow-right"></span>')
      $("#sign-up-sign-in-button").data('target', '#form_sign_in')
    else
      $("#sign-in-form").toggle()
      $("#sign-up-form").toggle('fade')
      $("#sign-up-sign-in-button").html('Create Account <span class="glyphicon glyphicon-arrow-right"></span>')
      $("#sign-up-sign-in-button").data('target', '#form_register')
    false
  )
  .on('click', '[data-object~="submit-tool-draft"]', () ->
    $("#draft").val('1')
    $($(this).data('target')).submit()
    false
  )
