@isNotInternetExplorer = () ->
  ua = window.navigator.userAgent
  msie = ua.indexOf('MSIE ')
  # If Internet Explorer, return version number
  if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))
    return false
  else # If another browser
    return true

@fileDragReady = () ->
  if window.FormData != undefined and isNotInternetExplorer()
    $('.filedrag').show()
