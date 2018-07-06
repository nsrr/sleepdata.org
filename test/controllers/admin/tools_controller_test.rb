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
      url: "https://github.com/nsrr/www.sleepdata.org",
      description: @tool.description,
      status: @tool.status
    }
  end

  test "should get index" do
    login(@admin)
    get admin_tools_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_admin_tool_url
    assert_response :success
  end

  test "should create tool" do
    login(@admin)
    assert_difference("Tool.count") do
      post admin_tools_url, params: { tool: tool_params }
    end
    assert_redirected_to admin_tool_url(Tool.last)
  end

  test "should show tool" do
    login(@admin)
    get admin_tool_url(@tool)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_admin_tool_url(@tool)
    assert_response :success
  end

  test "should update tool" do
    login(@admin)
    patch admin_tool_url(@tool), params: {
      tool: tool_params.merge(name: "Tool Name Update")
    }
    assert_redirected_to admin_tool_url(@tool)
  end

  test "should destroy tool" do
    login(@admin)
    assert_difference("Tool.current.count", -1) do
      delete admin_tool_url(@tool)
    end
    assert_redirected_to admin_tools_url
  end
end
