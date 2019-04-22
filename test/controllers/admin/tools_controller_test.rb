# frozen_string_literal: true

require "test_helper"

# Test for admin side of user-submitted tools.
class Admin::ToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tool = tools(:published)
    @admin = users(:admin)
  end

  def tool_params
    {
      name: "Tool Name",
      url: "https://github.com/nsrr/sleepdata.org",
      description: @tool.description,
      status: @tool.status
    }
  end

  test "should get index" do
    login(@admin)
    get admin_tools_url
    assert_response :success
  end

  test "should show tool" do
    login(@admin)
    get admin_tool_url(@tool)
    assert_response :success
  end

  test "should destroy tool" do
    login(@admin)
    assert_difference("Tool.current.count", -1) do
      delete admin_tool_url(@tool)
    end
    assert_redirected_to admin_tools_url
  end
end
