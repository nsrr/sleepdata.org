require 'test_helper'

SimpleCov.command_name 'test:controllers'

# TODO: Remove Controller
class WelcomeControllerTest < ActionController::TestCase
  test 'should get agreement reports for system admin' do
    login(users(:admin))
    get :agreement_reports
    assert_response :success
  end

  test 'should not get agreement reports for non system admin' do
    get :agreement_reports
    assert_redirected_to new_user_session_path
  end
end
