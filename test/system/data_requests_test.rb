# frozen_string_literal: true

require "application_system_test_case"

# Test user progress through a dataset access request.
class DataRequestsTest < ApplicationSystemTestCase
  setup do
    @regular = users(:regular)
    @released = datasets(:released)
    @started = data_requests(:started)
  end

  test "complete a signature agreement" do
    password = "password"
    @regular.update(password: password, password_confirmation: password)
    visit data_requests_start_url(@released)
    screenshot("dataset-request-signature")

    click_on "Click to start"
    screenshot("dataset-request-signature")

    click_on "I already have an account"

    fill_in "email", with: @regular.email
    fill_in "password", with: @regular.password
    click_form_submit

    screenshot("dataset-request-signature")
    click_on "Proceed"

    screenshot("dataset-request-signature")
    fill_in "specific_purpose", with: "This is my specific purpose."
    click_on "Proceed"

    sleep(0.5) # Allow time to setup canvas for drawing
    draw_on_canvas
    fill_in "signature_print", with: "Squiggles"
    screenshot("dataset-request-signature")
    click_on "Proceed"

    screenshot("dataset-request-signature")
    click_on "Skip"

    screenshot("dataset-request-signature")
    click_on "Submit"

    screenshot("dataset-request-signature")

    click_on "Review my data requests"
    screenshot("dataset-request-signature")
  end

  test "complete an attestation agreement" do
    password = "password"
    @regular.update(password: password, password_confirmation: password)
    visit data_requests_start_url(datasets(:orgtwo_hamlet))
    screenshot("dataset-request-attestation")

    click_on "Click to start"
    screenshot("dataset-request-attestation")

    click_on "I already have an account"

    fill_in "email", with: @regular.email
    fill_in "password", with: @regular.password
    click_form_submit

    screenshot("dataset-request-attestation")
    click_element_by_id "attest"

    click_on "Proceed"

    screenshot("dataset-request-attestation")
    click_on "Skip"

    screenshot("dataset-request-attestation")
    click_on "Submit"

    screenshot("dataset-request-attestation")

    click_on "Review my data requests"
    screenshot("dataset-request-attestation")
  end

  test "complete a fast agreement" do
    password = "password"
    @regular.update(password: password, password_confirmation: password)
    visit data_requests_start_url(datasets(:orgthree_crowd))
    screenshot("dataset-request-fast")

    click_on "Click to start"
    screenshot("dataset-request-fast")

    click_on "I already have an account"

    fill_in "email", with: @regular.email
    fill_in "password", with: @regular.password
    click_form_submit

    # screenshot("dataset-request-fast")
    # click_on "Skip"

    screenshot("dataset-request-fast")
    click_on "Submit"

    screenshot("dataset-request-fast")

    click_on "Review my data requests"
    screenshot("dataset-request-fast")
  end

  # data = window.$signaturePad.toData()
  # data[0].map(function(x) { return "{ x: " + x["x"] + ", y: " + x["y"] + ", time: " + x["time"] + " }"  }).join()
  def draw_on_canvas
    # page.execute_script("window.$signaturePad.fromData([[{ x: 100, y: 100 }]]);")
    page.execute_script("window.$signaturePad.fromData([[{ x: 63, y: 168.5, time: 1502737190899 },{ x: 67, y: 154.5, time: 1502737191382 },{ x: 69, y: 141.5, time: 1502737191400 },{ x: 71, y: 134.5, time: 1502737191416 },{ x: 73, y: 127.5, time: 1502737191434 },{ x: 76, y: 115.5, time: 1502737191450 },{ x: 78, y: 112.5, time: 1502737191468 },{ x: 82, y: 103.5, time: 1502737191485 },{ x: 85, y: 99.5, time: 1502737191503 },{ x: 94, y: 91.5, time: 1502737191520 },{ x: 102, y: 86.5, time: 1502737191538 },{ x: 113, y: 82.5, time: 1502737191555 },{ x: 118, y: 81.5, time: 1502737191572 },{ x: 124, y: 81.5, time: 1502737191589 },{ x: 126, y: 81.5, time: 1502737191606 },{ x: 129, y: 83.5, time: 1502737191624 },{ x: 135, y: 94.5, time: 1502737191640 },{ x: 140, y: 108.5, time: 1502737191657 },{ x: 150, y: 138.5, time: 1502737191673 },{ x: 156, y: 171.5, time: 1502737191690 },{ x: 157, y: 180.5, time: 1502737191707 },{ x: 158, y: 200.5, time: 1502737191723 },{ x: 158, y: 207.5, time: 1502737191740 },{ x: 158, y: 220.5, time: 1502737191757 },{ x: 158, y: 226.5, time: 1502737191773 },{ x: 158, y: 238.5, time: 1502737191790 },{ x: 159, y: 245.5, time: 1502737191807 },{ x: 161, y: 254.5, time: 1502737191823 },{ x: 163, y: 257.5, time: 1502737191840 },{ x: 169, y: 262.5, time: 1502737191857 },{ x: 170, y: 263.5, time: 1502737191873 },{ x: 173, y: 264.5, time: 1502737191890 },{ x: 175, y: 264.5, time: 1502737191907 },{ x: 182, y: 264.5, time: 1502737191924 },{ x: 189, y: 262.5, time: 1502737191940 },{ x: 201, y: 258.5, time: 1502737191957 },{ x: 207, y: 254.5, time: 1502737191973 },{ x: 221, y: 243.5, time: 1502737191990 },{ x: 231, y: 232.5, time: 1502737192007 },{ x: 253, y: 195.5, time: 1502737192023 },{ x: 257, y: 181.5, time: 1502737192040 },{ x: 261, y: 152.5, time: 1502737192057 },{ x: 261, y: 145.5, time: 1502737192074 },{ x: 261, y: 129.5, time: 1502737192090 },{ x: 261, y: 121.5, time: 1502737192107 },{ x: 261, y: 115.5, time: 1502737192123 },{ x: 263, y: 99.5, time: 1502737192140 },{ x: 264, y: 92.5, time: 1502737192157 },{ x: 271, y: 80.5, time: 1502737192174 },{ x: 275, y: 74.5, time: 1502737192191 },{ x: 282, y: 68.5, time: 1502737192208 },{ x: 286, y: 66.5, time: 1502737192224 },{ x: 294, y: 63.5, time: 1502737192240 },{ x: 298, y: 62.5, time: 1502737192257 },{ x: 303, y: 63.5, time: 1502737192274 },{ x: 305, y: 64.5, time: 1502737192290 },{ x: 313, y: 75.5, time: 1502737192307 },{ x: 318, y: 82.5, time: 1502737192324 },{ x: 329, y: 104.5, time: 1502737192341 },{ x: 332, y: 114.5, time: 1502737192357 },{ x: 333, y: 132.5, time: 1502737192374 },{ x: 333, y: 146.5, time: 1502737192391 },{ x: 331, y: 171.5, time: 1502737192407 },{ x: 330, y: 185.5, time: 1502737192424 },{ x: 327, y: 210.5, time: 1502737192441 },{ x: 326, y: 222.5, time: 1502737192457 },{ x: 326, y: 237.5, time: 1502737192474 },{ x: 327, y: 241.5, time: 1502737192491 },{ x: 330, y: 247.5, time: 1502737192507 },{ x: 332, y: 250.5, time: 1502737192525 },{ x: 338, y: 255.5, time: 1502737192541 },{ x: 342, y: 257.5, time: 1502737192558 },{ x: 355, y: 260.5, time: 1502737192574 },{ x: 367, y: 261.5, time: 1502737192591 },{ x: 379, y: 261.5, time: 1502737192607 },{ x: 396, y: 258.5, time: 1502737192624 },{ x: 403, y: 256.5, time: 1502737192641 },{ x: 415, y: 252.5, time: 1502737192658 },{ x: 419, y: 247.5, time: 1502737192675 },{ x: 426, y: 236.5, time: 1502737192691 },{ x: 430, y: 227.5, time: 1502737192707 },{ x: 440, y: 202.5, time: 1502737192724 },{ x: 444, y: 191.5, time: 1502737192741 },{ x: 452, y: 166.5, time: 1502737192758 },{ x: 456, y: 155.5, time: 1502737192774 },{ x: 461, y: 136.5, time: 1502737192791 },{ x: 465, y: 124.5, time: 1502737192807 },{ x: 472, y: 105.5, time: 1502737192824 },{ x: 478, y: 92.5, time: 1502737192841 },{ x: 487, y: 74.5, time: 1502737192857 },{ x: 490, y: 71.5, time: 1502737192874 },{ x: 493, y: 69.5, time: 1502737192891 },{ x: 494, y: 69.5, time: 1502737192908 },{ x: 500, y: 69.5, time: 1502737192924 },{ x: 502, y: 69.5, time: 1502737192941 },{ x: 509, y: 72.5, time: 1502737192958 },{ x: 512, y: 75.5, time: 1502737192974 },{ x: 517, y: 82.5, time: 1502737192991 },{ x: 519, y: 87.5, time: 1502737193008 },{ x: 521, y: 100.5, time: 1502737193024 },{ x: 522, y: 112.5, time: 1502737193042 },{ x: 524, y: 134.5, time: 1502737193058 },{ x: 524, y: 146.5, time: 1502737193074 },{ x: 526, y: 164.5, time: 1502737193091 },{ x: 527, y: 174.5, time: 1502737193108 },{ x: 528, y: 191.5, time: 1502737193124 },{ x: 528, y: 204.5, time: 1502737193141 },{ x: 528, y: 209.5, time: 1502737193158 },{ x: 528, y: 223.5, time: 1502737193175 },{ x: 529, y: 227.5, time: 1502737193191 },{ x: 532, y: 234.5, time: 1502737193208 },{ x: 534, y: 237.5, time: 1502737193225 },{ x: 538, y: 241.5, time: 1502737193241 },{ x: 541, y: 243.5, time: 1502737193258 },{ x: 547, y: 246.5, time: 1502737193274 },{ x: 551, y: 247.5, time: 1502737193291 },{ x: 557, y: 249.5, time: 1502737193308 },{ x: 562, y: 249.5, time: 1502737193325 },{ x: 576, y: 249.5, time: 1502737193341 },{ x: 581, y: 249.5, time: 1502737193359 },{ x: 592, y: 249.5, time: 1502737193375 },{ x: 597, y: 248.5, time: 1502737193392 },{ x: 605, y: 246.5, time: 1502737193408 },{ x: 609, y: 244.5, time: 1502737193425 },{ x: 616, y: 237.5, time: 1502737193441 },{ x: 620, y: 232.5, time: 1502737193458 },{ x: 628, y: 215.5, time: 1502737193475 },{ x: 633, y: 203.5, time: 1502737193491 },{ x: 653, y: 168.5, time: 1502737193508 },{ x: 661, y: 153.5, time: 1502737193525 },{ x: 676, y: 120.5, time: 1502737193541 },{ x: 679, y: 113.5, time: 1502737193558 },{ x: 680, y: 106.5, time: 1502737193575 },{ x: 679, y: 94.5, time: 1502737193592 },{ x: 679, y: 91.5, time: 1502737193608 },{ x: 679, y: 85.5, time: 1502737193625 },{ x: 679, y: 84.5, time: 1502737193642 },{ x: 679, y: 83.5, time: 1502737193658 }]]);")
  end
end
