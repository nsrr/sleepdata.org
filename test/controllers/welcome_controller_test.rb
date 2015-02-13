require 'test_helper'

SimpleCov.command_name "test:controllers"

class WelcomeControllerTest < ActionController::TestCase

  test "should get stats for system admin" do
    login(users(:admin))
    get :stats
    assert_response :success
  end

  test "should not get stats for non system admin" do
    get :stats
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

  test "should get about" do
    get :about
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should get aug" do
    get :aug
    assert_not_nil assigns(:users)
    assert_equal 1, assigns(:users).count
    assert_response :success
  end

  test "should get collection" do
    get :collection
    assert_not_nil assigns(:datasets)
    assert_response :success
  end

  test "should get collection with search term" do
    get :collection, s: 'gender'
    assert_not_nil assigns(:datasets)
    assert assigns(:variables).count > 0
    assert_response :success
  end

  test "should get collection for logged in user" do
    login(users(:valid))
    get :collection
    assert_not_nil assigns(:datasets)
    assert_response :success
  end

  test "should get collection modal" do
    xhr :get, :collection_modal, slug: 'wecare', basename: 'gender', format: 'js'
    assert_not_nil assigns(:dataset)
    assert assigns(:variable)
    assert_response :success
  end

  test "should get collection modal for logged in user" do
    login(users(:valid))
    xhr :get, :collection_modal, slug: 'wecare', basename: 'gender', format: 'js'
    assert_not_nil assigns(:dataset)
    assert assigns(:variable)
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get index2" do
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
