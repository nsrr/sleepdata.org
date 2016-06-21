@turbolinksReady = ->
  # Don't cache pages with Turbolinks
  Turbolinks.pagesCached(0)
  Turbolinks.allowLinkExtensions('md')
  Turbolinks.enableProgressBar()
