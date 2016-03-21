# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:valid)
  end

  test "should get settings for valid user" do
    login(users(:valid))
    get :settings
    assert_response :success
  end

  test "should not get settings for anonymous user" do
    get :settings
    assert_redirected_to new_user_session_path
  end

  test "should get index for system admin" do
    login(users(:admin))
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(users(:valid))
    get :index
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should show user for system admin" do
    login(users(:admin))
    get :show, id: @user
    assert_response :success
  end

  test "should get edit for system admin" do
    login(users(:admin))
    get :edit, id: @user
    assert_response :success
  end

  test "should update user for system admin" do
    login(users(:admin))
    put :update, id: @user, user: { first_name: 'FirstName', last_name: 'LastName', email: 'valid_updated_email@example.com', system_admin: false }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user with blank name" do
    login(users(:admin))
    put :update, id: @user, user: { first_name: '', last_name: '' }
    assert_not_nil assigns(:user)
    assert_template 'edit'
  end

  test "should not update user with invalid id" do
    login(users(:admin))
    put :update, id: -1, user: { first_name: 'FirstName', last_name: 'LastName', email: 'valid_updated_email@example.com', system_admin: false }
    assert_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should destroy user for system admin" do
    login(users(:admin))
    assert_difference('User.current.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end


end
