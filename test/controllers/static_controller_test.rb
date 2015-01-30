require 'test_helper'

class StaticControllerTest < ActionController::TestCase

  setup do
    @regular_user = users(:valid)
  end

  test "should get demo for logged out user" do
    get :demo
    assert_response :success
  end

  test "should get demo for regular user" do
    login(@regular_user)
    get :demo
    assert_response :success
  end

end
