$(document)
  .on("click", "[data-object~=select-username]", ->
    document.querySelector("#user_username").value = this.getAttribute("data-username")
    document.querySelector("#user_username").classList.remove("is-invalid")
    false
  )
