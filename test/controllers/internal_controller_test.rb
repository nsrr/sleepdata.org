# frozen_string_literal: true

require "test_helper"

# Tests for internal user pages.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get dashboard" do
    login(@regular)
    get dashboard_url
    assert_response :success
  end

  test "should get token" do
    login(@regular)
    get token_url
    assert_response :success
  end
end
