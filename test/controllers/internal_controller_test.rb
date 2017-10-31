# frozen_string_literal: true

require "test_helper"

# Tests for internal user pages.
class InternalControllerTest < ActionController::TestCase
  test "should get dashboard as regular user" do
    login(users(:regular))
    get :dashboard
    assert_response :success
  end

  # test "should get settings" do
  #   get :settings
  #   assert_response :success
  # end

  # test "should get tools" do
  #   get :tools
  #   assert_response :success
  # end

  test "should get profile" do
    login(users(:regular))
    get :profile
    assert_response :success
  end

  test "should get token" do
    login(users(:regular))
    get :token
    assert_response :success
  end
end
