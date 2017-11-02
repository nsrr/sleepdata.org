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
      first_name: "New",
      last_name: "User",
      email: "new_user@example.com",
      system_admin: false
    }
  end

  test "should get index for system admin" do
    login(@admin)
    get users_path
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(@regular)
    get users_path
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should show user for system admin" do
    login(@admin)
    get user_path(@user)
    assert_response :success
  end

  test "should get edit for system admin" do
    login(@admin)
    get edit_user_path(@user)
    assert_response :success
  end

  test "should update user for system admin" do
    login(@admin)
    patch user_path(@user), params: { user: user_hash }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    login(@admin)
    patch user_path(@user), params: { user: user_hash.merge(first_name: "", last_name: "") }
    assert_not_nil assigns(:user)
    assert_template "edit"
  end

  test "should not update user with invalid id" do
    login(@admin)
    patch user_path(-1), params: { user: user_hash }
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should destroy user for admin" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete user_path(@user)
    end
    assert_redirected_to users_path
  end

  test "should destroy user for admin with ajax" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete user_path(@user, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
