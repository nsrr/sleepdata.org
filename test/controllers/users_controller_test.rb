# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:controllers"

# Tests to make sure users can be modified by administrators.
class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @regular = users(:regular)
    @admin = users(:admin)
  end

  def user_hash
    {
      full_name: "New User",
      email: "newuser@example.com",
      admin: false
    }
  end

  test "should get index for admin" do
    login(@admin)
    get users_url
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-admin" do
    login(@regular)
    get users_url
    assert_nil assigns(:users)
    assert_redirected_to root_url
  end

  test "should show user for admin" do
    login(@admin)
    get user_url(@user)
    assert_response :success
  end

  test "should get edit for admin" do
    login(@admin)
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user for admin" do
    login(@admin)
    patch user_url(@user), params: { user: user_hash }
    assert_redirected_to user_url(assigns(:user))
  end

  test "should not update user with blank username" do
    login(@admin)
    patch user_url(@user), params: { user: user_hash.merge(username: "") }
    assert_not_nil assigns(:user)
    assert_template "edit"
  end

  test "should not update user with invalid id" do
    login(@admin)
    patch user_url(-1), params: { user: user_hash }
    assert_nil assigns(:user)
    assert_redirected_to users_url
  end

  test "should destroy user for admin" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete user_url(@user)
    end
    assert_redirected_to users_url
  end

  test "should destroy user for admin with ajax" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete user_url(@user, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
