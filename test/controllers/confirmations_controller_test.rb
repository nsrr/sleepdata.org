# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unconfirmed = users(:unconfirmed)
  end

  test "should confirm email and redirect to data request" do
    get user_confirmation_url(
      confirmation_token: @unconfirmed.confirmation_token,
      data_request_id: data_requests(:unconfirmed).id
    )
    assert_redirected_to resume_data_request_url(data_requests(:unconfirmed).id)
  end

  test "should confirm email and redirect to dashboard" do
    get user_confirmation_url(confirmation_token: @unconfirmed.confirmation_token)
    assert_redirected_to dashboard_url
  end
end
