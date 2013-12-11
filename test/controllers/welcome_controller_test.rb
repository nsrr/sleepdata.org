require 'test_helper'

SimpleCov.command_name "test:controllers"

class WelcomeControllerTest < ActionController::TestCase
  test "should get collection" do
    get :collection
    assert_not_nil assigns(:datasets)
    assert_response :success
  end

  test "should get collection for logged in user" do
    login(users(:valid))
    get :collection
    assert_not_nil assigns(:datasets)
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get wget_src" do
    get :wget_src
    assert_template 'tools/wget/wget_src'
    assert_response :success
  end

  test "should get wget_windows" do
    get :wget_windows
    assert_template 'tools/wget/wget_windows'
    assert_response :success
  end

end
