require 'test_helper'

SimpleCov.command_name "test:controllers"

class WelcomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
