require 'test_helper'

# This controller tests simultaneous registration and form submission
class RequestControllerTest < ActionController::TestCase
  test 'should get tool contribute' do
    get :tool_contribute
    assert_response :success
  end

  test 'should get tool request' do
    get :tool_request
    assert_response :success
  end

  test 'should get dataset hosting' do
    get :dataset_hosting
    assert_response :success
  end
end
