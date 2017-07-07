# frozen_string_literal: true

require "test_helper"

# Tests for admin controller
class AdminControllerTest < ActionController::TestCase
  test "should get roles for admin" do
    login(users(:admin))
    get :roles
    assert_response :success
  end

  test "should not get roles for regular user" do
    login(users(:valid))
    get :roles
    assert_redirected_to root_path
  end

  test "should not get roles for public user" do
    get :roles
    assert_redirected_to new_user_session_path
  end

  test "should get stats for admin" do
    login(users(:admin))
    get :stats
    assert_response :success
  end

  test "should not get stats for regular user" do
    login(users(:valid))
    get :stats
    assert_redirected_to root_path
  end

  test "should not get stats for public user" do
    get :stats
    assert_redirected_to new_user_session_path
  end

  test "should get sync for admin" do
    login(users(:admin))
    get :sync
    assert_response :success
  end

  test "should not get sync for regular user" do
    login(users(:valid))
    get :sync
    assert_redirected_to root_path
  end

  test "should not get sync for public user" do
    get :sync
    assert_redirected_to new_user_session_path
  end

  test "should get agreement reports for system admin" do
    login(users(:admin))
    get :agreement_reports
    assert_response :success
  end

  test "should not get agreement reports for non system admin" do
    get :agreement_reports
    assert_redirected_to new_user_session_path
  end

  test "should get downloads by month for system admin" do
    login(users(:admin))
    get :downloads_by_month
    assert_response :success
  end

  test "should not get downloads by month for non system admin" do
    get :downloads_by_month
    assert_redirected_to new_user_session_path
  end

  test "should get downloads by quarter for system admin" do
    login(users(:admin))
    get :downloads_by_quarter
    assert_response :success
  end

  test "should not get downloads by quarter for non system admin" do
    get :downloads_by_quarter
    assert_redirected_to new_user_session_path
  end
end
