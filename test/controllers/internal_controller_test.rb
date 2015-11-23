require 'test_helper'

# Tests for personal member pages
class InternalControllerTest < ActionController::TestCase
  setup do
    @regular_user = login(users(:valid))
  end

  test 'should get dashboard' do
    get :dashboard
    assert_response :success
  end

  # test 'should get settings' do
  #   get :settings
  #   assert_response :success
  # end

  # test 'should get submissions' do
  #   get :submissions
  #   assert_response :success
  # end

  # test 'should get tools' do
  #   get :tools
  #   assert_response :success
  # end

  test 'should get profile' do
    get :profile
    assert_response :success
  end
end
