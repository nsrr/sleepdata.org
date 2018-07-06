# frozen_string_literal: true

require "test_helper"

# Allows users to view and explore tools.
class ToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = tools(:published)
    @draft = tools(:draft)
  end

  test "should get index" do
    get tools_url
    assert_response :success
  end

  test "should show tool" do
    get tool_url(@published)
    assert_response :success
  end

  test "should show draft for tool creator" do
    login(@draft.user)
    get tool_url(@draft)
    assert_response :success
  end

  test "should not show draft tool for public user" do
    get tool_url(@draft)
    assert_redirected_to tools_url
  end
end
