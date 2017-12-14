$(document)
  .on("click", "[data-object~=toggle-search-container]", ->
    $(".search-container").toggleClass("search-container-visible")
    setFocusToField($(this).data("target"))
    false
  )
