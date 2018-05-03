# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:integration"

# Tests to assure that user navigation is working as intended.
class NavigationTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @regular = users(:regular)
    @unconfirmed = users(:unconfirmed)
    @deleted = users(:deleted)
  end

  test "should get root path" do
    get "/"
    assert_equal "/", path
  end

  test "should get sign up page" do
    get new_user_registration_path
    assert_equal new_user_registration_path, path
    assert_response :success
  end

  test "should register new account" do
    post user_registration_path, params: {
      user: {
        username: "registeraccount",
        email: "register@account.com",
        password: "registerpassword098765"
      }
    }
    assert_equal I18n.t("devise.registrations.signed_up_but_unconfirmed"), flash[:notice]
    assert_redirected_to root_path
  end

  test "should not login unconfirmed user" do
    get new_user_session_path
    login(@unconfirmed)
    assert_equal new_user_session_path, path
  end

  test "should not login deleted user" do
    get new_user_session_path
    login(@deleted)
    assert_equal new_user_session_path, path
  end

  test "friendly url forwarding after login" do
    get datasets_path
    get new_user_session_path
    login(@regular)
    assert_equal datasets_path, path
  end

  test "friendly url forwarding after logout" do
    get datasets_path
    login(@regular)
    get datasets_path
    get destroy_user_session_path
    assert_redirected_to datasets_path
  end

  test "blog rss should not be stored in friendly forwarding after login" do
    get blog_path(format: "atom")
    get new_user_session_path
    login(@regular)
    assert_equal root_path, path
  end
end
