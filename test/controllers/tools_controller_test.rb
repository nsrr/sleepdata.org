# frozen_string_literal: true

require "test_helper"

# Allows users to view articles in tools category.
class ToolsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tools_url
    assert_response :success
  end
end
