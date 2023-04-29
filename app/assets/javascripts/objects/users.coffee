$(document)
  .on("click", "[data-object~=select-username]", ->
    document.querySelector("#user_username").value = this.getAttribute("data-username")
    document.querySelector("#user_username").classList.remove("is-invalid")
    false
  )
  .on("keyup blur", "[data-object~=format-orcidid]", ->
    # (1) Only select numbers
    # (2) Split into sets of 4
    # (3) Join all sets with a dash and truncate the string to 19 characters: 0000-0000-0000-0000
    value = $(this).val().match(/[X\d]/g) || []
    value = value.join("").match(/.{1,4}/g) || []
    value = value.join("-").substring(0, 19)
    $(this).val(value)
  )
