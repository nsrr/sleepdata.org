# frozen_string_literal: true

require "test_helper"

# Test user settings pages.
class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get settings" do
    login(@regular)
    get settings_url
    assert_redirected_to settings_profile_url
  end

  test "should get profile for regular user" do
    login(@regular)
    get settings_profile_url
    assert_response :success
  end

  test "should not get profile for public user" do
    get settings_profile_url
    assert_redirected_to new_user_session_url
  end

  test "should get account" do
    login(@regular)
    get settings_account_url
    assert_response :success
  end

  test "should get email" do
    login(@regular)
    get settings_email_url
    assert_response :success
  end

  test "should update account" do
    login(@regular)
    patch settings_update_account_url, params: {
      user: { username: "newusername" }
    }
    assert_equal "Account successfully updated.", flash[:notice]
    assert_redirected_to settings_account_url
  end

  test "should update password" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_equal "Your password has been changed.", flash[:notice]
    assert_redirected_to settings_account_url
  end

  test "should not update password as user with invalid current password" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "invalid",
        password: "newpassword",
        password_confirmation: "newpassword"
      }
    }
    assert_template "account"
    assert_response :success
  end

  test "should not update password with new password mismatch" do
    sign_in_as(@regular, "password")
    patch settings_update_password_url, params: {
      user: {
        current_password: "password",
        password: "newpassword",
        password_confirmation: "mismatched"
      }
    }
    assert_template "account"
    assert_response :success
  end

  test "should delete account" do
    login(@regular)
    assert_difference("User.current.count", -1) do
      delete settings_delete_account_url
    end
    assert_redirected_to root_url
  end

  test "should get data request preferences" do
    login(@regular)
    get settings_data_requests_url
    assert_response :success
  end

  test "should update data request preferences" do
    login(@regular)
    patch settings_update_data_requests_url, params: {
      user: { data_user_type: "organization", commercial_type: "commercial" }
    }
    @regular.reload
    assert_equal "organization", @regular.data_user_type
    assert_equal "commercial", @regular.commercial_type
    assert_equal "Preferences successfully updated.", flash[:notice]
    assert_redirected_to settings_data_requests_url
  end
end
