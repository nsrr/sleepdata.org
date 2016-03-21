# frozen_string_literal: true

require 'test_helper'

# Test for admin side of community tools
class CommunityToolsControllerTest < ActionController::TestCase
  setup do
    @community_tool = community_tools(:submitted)
    login(users(:admin))
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:community_tools)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create community_tool' do
    assert_difference('CommunityTool.count') do
      post :create, params: { community_tool: { name: 'Community Tool Name', url: 'https://github.com/nsrr/www.sleepdata.org', description: @community_tool.description, status: @community_tool.status } }
    end

    assert_redirected_to community_tool_path(assigns(:community_tool))
  end

  test 'should show community_tool' do
    get :show, params: { id: @community_tool }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @community_tool }
    assert_response :success
  end

  test 'should update community_tool' do
    patch :update, params: { id: @community_tool, community_tool: { name: 'Community Tool Name Update', url: 'https://github.com/nsrr/www.sleepdata.org', description: @community_tool.description, status: @community_tool.status } }
    assert_redirected_to community_tool_path(assigns(:community_tool))
  end

  test 'should destroy community_tool' do
    assert_difference('CommunityTool.current.count', -1) do
      delete :destroy, params: { id: @community_tool }
    end

    assert_redirected_to community_tools_path
  end
end
