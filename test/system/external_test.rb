# frozen_string_literal: true

require "application_system_test_case"

# Test external pages.
class ExternalTest < ApplicationSystemTestCase
  test "visiting the about page" do
    visit about_url
    screenshot("visit-about-page")
    page.execute_script("window.scrollBy(0, $(\"body\").height());")
    screenshot("visit-about-page")
  end

  test "visiting the team page" do
    visit team_url
    screenshot("visit-team-page")
  end

  test "visiting the aug page" do
    visit aug_url
    screenshot("visit-aug-page")
  end

  test "visiting the past contributors page" do
    visit contributors_url
    screenshot("visit-past-contributors-page")
  end
end
