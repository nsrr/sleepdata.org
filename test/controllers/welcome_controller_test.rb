require 'test_helper'

SimpleCov.command_name 'test:controllers'

# TODO: Remove Controller
class WelcomeControllerTest < ActionController::TestCase
  test 'should get stats for system admin' do
    login(users(:admin))
    get :stats
    assert_response :success
  end

  test 'should not get stats for non system admin' do
    get :stats
    assert_redirected_to new_user_session_path
  end

  test 'should get agreement reports for system admin' do
    login(users(:admin))
    get :agreement_reports
    assert_response :success
  end

  test 'should not get agreement reports for non system admin' do
    get :agreement_reports
    assert_redirected_to new_user_session_path
  end

  test 'should get aug' do
    get :aug
    assert_not_nil assigns(:users)
    assert_equal 1, assigns(:users).count
    assert_response :success
  end

  test 'should get contact' do
    get :contact
    assert_response :success
  end
end
