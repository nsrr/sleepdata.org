# frozen_string_literal: true

require "application_system_test_case"

# System tests for organizations.
class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
  end

  test "visiting the index" do
    password = "PASSword2"
    @admin.update(password: password, password_confirmation: password)
    visit root_url
    screenshot("organizations-index")
    click_on "Sign in"
    screenshot("organizations-index")
    fill_in "user[email]", with: @admin.email
    fill_in "user[password]", with: @admin.password
    click_form_submit
    visit organizations_url
    screenshot("organizations-index")
    assert_selector "h1", text: "Organization"
  end
end
