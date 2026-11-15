# frozen_string_literal: true

require "application_system_test_case"

# System tests for organizations.
class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
  end

  test "visiting the index" do
    visit root_url
    screenshot("organizations-index")
    click_on "Sign in"
    sign_in_with_attestation_user_form @admin, password: "password"
    visit organizations_url
    screenshot("organizations-index")
    assert_selector "h1", text: "Organization"
  end
end
