@csrfToken = ->
  document.querySelector("meta[name=csrf-token]").content
