# frozen_string_literal: true

require "test_helper"

# Tests JSON API for account authentication.
class Api::V1::AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get profile as regular user" do
    get api_v1_account_profile_url(auth_token: users(:regular).id_and_auth_token, format: "json")
    profile = JSON.parse(response.body)
    assert_equal true, profile["authenticated"]
    assert_equal "Regular", profile["first_name"]
    assert_equal "User", profile["last_name"]
    assert_equal "Regular User", profile["full_name"]
    assert_equal "regular", profile["username"]
    assert_response :success
  end

  test "should get profile as logged out viewer" do
    get api_v1_account_profile_url(format: "json")
    profile = JSON.parse(response.body)
    assert_equal false, profile["authenticated"]
    assert_nil profile["first_name"]
    assert_nil profile["last_name"]
    assert_nil profile["full_name"]
    assert_nil profile["username"]
    assert_response :success
  end
end
