# frozen_string_literal: true

require "test_helper"

# Set up ApplicationSystemTestCase system tests.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400] do |driver_options|
    driver_options.add_preference("profile.password_manager_leak_detection", false)
    driver_options.add_preference("credentials_enable_service", false)
  end

  setup do
    @screenshots_enabled = true
    @counter = 0
  end

  def screenshot(file_name)
    return unless @screenshots_enabled

    @counter += 1
    relative_location = File.join(
      "docs",
      SleepData::VERSION::STRING,
      "screenshots",
      "#{file_name}-#{format("%02d", @counter)}.png"
    )
    page.save_screenshot(Rails.root.join(relative_location))
    # puts "[Screenshot]: #{relative_location}"
  end

  def click_form_submit
    find("input[type=submit]").click
    sleep 1
  end

  def click_element(selector)
    page.execute_script("$(\"#{selector}\").click();")
  end

  def sign_in_with_attestation(user, password: nil)
    fill_in "email", with: user.email
    fill_in "password", with: password.presence || user.password
    first("#login_not_covered_person_or_located_in_country_of_concern_attestation", visible: :all).check(allow_label_click: true)
    click_form_submit
  end

  def sign_in_with_attestation_user_form(user, password: nil)
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: password.presence || user.password
    first("#login_not_covered_person_or_located_in_country_of_concern_attestation", visible: :all).check(allow_label_click: true)
    click_form_submit
  end
end
