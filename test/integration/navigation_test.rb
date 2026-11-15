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
    get new_user_registration_url
    assert_equal new_user_registration_path, path
    assert_response :success
  end

  test "should register new account" do
    post user_registration_url, params: {
      user: {
        username: "registeraccount",
        email: "register@account.com",
        password: "registerpassword098765",
        not_covered_person_or_located_in_country_of_concern_attestation: "1"
      }
    }
    assert_equal I18n.t("devise.registrations.signed_up_but_unconfirmed"), flash[:notice]
    assert_redirected_to root_url
    assert_not_nil User.find_by(email: "register@account.com").not_covered_person_country_of_concern_attestation_at
  end

  test "should not register new account without attestation" do
    assert_difference("User.count", 0) do
      post user_registration_url, params: {
        user: {
          username: "registeraccount",
          email: "register@account.com",
          password: "registerpassword098765",
          not_covered_person_or_located_in_country_of_concern_attestation: "0"
        }
      }
    end
    assert_response :success
    assert_match "must be accepted", response.body
  end

  test "should not register new account with missing attestation" do
    assert_difference("User.count", 0) do
      post user_registration_url, params: {
        user: {
          username: "registeraccount",
          email: "register@account.com",
          password: "registerpassword098765"
        }
      }
    end
    assert_response :success
  end

  test "should record attestation time on login" do
    assert_nil @regular.not_covered_person_country_of_concern_attestation_at
    login(@regular)
    assert_not_nil @regular.reload.not_covered_person_country_of_concern_attestation_at
  end

  test "should update attestation time on subsequent login" do
    old_time = 1.day.ago.change(usec: 0)
    @regular.update_column :not_covered_person_country_of_concern_attestation_at, old_time
    login(@regular)
    assert_operator @regular.reload.not_covered_person_country_of_concern_attestation_at, :>, old_time
  end

  test "should not login without attestation" do
    @regular.update password: "1234567890", password_confirmation: "1234567890"
    post new_user_session_url, params: {
      user: { email: @regular.email, password: "1234567890", not_covered_person_or_located_in_country_of_concern_attestation: "0" }
    }
    assert_response :success
    assert_match "must be accepted", response.body
    assert_nil @regular.reload.not_covered_person_country_of_concern_attestation_at
    assert_nil session["warden.user.user.key"]
  end

  test "should not login without attestation params" do
    post new_user_session_url, params: { user: { email: @regular.email, password: "1234567890" } }
    assert_response :success
  end

  test "should not login unconfirmed user" do
    get new_user_session_url
    login(@unconfirmed)
    assert_equal new_user_session_path, path
  end

  test "should not login deleted user" do
    get new_user_session_url
    login(@deleted)
    assert_equal new_user_session_path, path
  end

  test "friendly url forwarding after login" do
    get datasets_url
    get new_user_session_url
    login(@regular)
    assert_equal datasets_path, path
  end

  test "friendly url forwarding after logout" do
    get datasets_url
    login(@regular)
    get datasets_url
    get destroy_user_session_url
    assert_redirected_to datasets_url
  end

  test "blog rss should not be stored in friendly forwarding after login" do
    get blog_url(format: "atom")
    get new_user_session_url
    login(@regular)
    assert_equal root_path, path
  end
end
