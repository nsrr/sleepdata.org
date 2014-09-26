require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  test "should get dashboard for system admin" do
    login(users(:admin))
    get :dashboard
    assert_response :success
  end

  test "should not get dashboard for non-system admin" do
    login(users(:valid))
    get :dashboard
    assert_redirected_to root_path
  end

  test "should not get dashboard for anonymous user" do
    get :dashboard
    assert_redirected_to new_user_session_path
  end

end
