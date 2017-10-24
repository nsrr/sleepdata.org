# frozen_string_literal: true

require "test_helper"

# Test for admin side of community tools.
class CommunityToolsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @community_tool = community_tools(:published)
    @admin = users(:admin)
  end

  def tool_params
    {
      name: "Community Tool Name",
      url: "https://github.com/nsrr/www.sleepdata.org",
      description: @community_tool.description,
      status: @community_tool.status
    }
  end

  test "should get index" do
    login(@admin)
    get community_tools_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_community_tool_url
    assert_response :success
  end

  test "should create community tool" do
    login(@admin)
    assert_difference("CommunityTool.count") do
      post community_tools_url, params: { community_tool: tool_params }
    end
    assert_redirected_to community_tool_path(CommunityTool.last)
  end

  test "should show community tool" do
    login(@admin)
    get community_tool_url(@community_tool)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_community_tool_url(@community_tool)
    assert_response :success
  end

  test "should update community tool" do
    login(@admin)
    patch community_tool_url(@community_tool), params: {
      community_tool: tool_params.merge(name: "Community Tool Name Update")
    }
    assert_redirected_to community_tool_path(@community_tool)
  end

  test "should destroy community tool" do
    login(@admin)
    assert_difference("CommunityTool.current.count", -1) do
      delete community_tool_url(@community_tool)
    end
    assert_redirected_to community_tools_path
  end
end
