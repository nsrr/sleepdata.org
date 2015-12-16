require 'test_helper'

# Tests for personal member pages
class InternalControllerTest < ActionController::TestCase
  test 'should get dashboard as regular user' do
    login(users(:valid))
    get :dashboard
    assert_response :success
  end

  # test 'should get settings' do
  #   get :settings
  #   assert_response :success
  # end

  test 'should get submissions as regular user' do
    login(users(:valid))
    get :submissions
    assert_response :success
  end

  test 'should not get submissions for public user' do
    get :submissions
    assert_redirected_to new_user_session_path
  end

  # test 'should get tools' do
  #   get :tools
  #   assert_response :success
  # end

  test 'should get profile' do
    login(users(:valid))
    get :profile
    assert_response :success
  end
end
