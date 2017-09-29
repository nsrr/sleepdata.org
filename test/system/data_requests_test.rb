# frozen_string_literal: true

require "application_system_test_case"

# Test user progress through a dataset access request.
class DataRequestsTest < ApplicationSystemTestCase
  setup do
    @regular = users(:regular)
    @released = datasets(:released)
    @started = agreements(:started)
  end

  test "completing a data request" do
    password = "password"
    @regular.update(password: password, password_confirmation: password)
    visit data_requests_start_url(@released)
    screenshot("dataset-requests")

    click_on "Sign in"
    screenshot("dataset-requests")
    fill_in "user[email]", with: @regular.email
    fill_in "user[password]", with: @regular.password
    click_form_submit

    visit data_requests_request_as_individual_or_organization_url(@released)
    screenshot("dataset-requests")
    click_on "I am an individual"

    visit data_requests_intended_use_noncommercial_or_commercial_url(@released)
    screenshot("dataset-requests")
    click_on "My intended use is noncommercial"

    visit data_requests_page_url(@started, "1")
    screenshot("dataset-requests")

    visit data_requests_attest_url(@started)
    screenshot("dataset-requests")

    visit data_requests_addendum_url(@started, "1")
    screenshot("dataset-requests")

    visit data_requests_addons_url(@started)
    screenshot("dataset-requests")

    visit data_requests_proof_url(@started)
    screenshot("dataset-requests")

    visit data_requests_submitted_url(@started)
    screenshot("dataset-requests")

    visit data_requests_print_url(@started)
    screenshot("dataset-requests")
  end
end
