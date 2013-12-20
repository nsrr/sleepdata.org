require 'test_helper'

class ToolsControllerTest < ActionController::TestCase
  setup do
    @tool = tools(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tools)
  end

  test "should get new" do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test "should create tool" do
    login(users(:admin))
    assert_difference('Tool.count') do
      post :create, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: @tool.name, slug: 'new_tool', description: @tool.description }
    end

    assert_redirected_to tool_path(assigns(:tool))
  end

  test "should show tool" do
    get :show, id: @tool
    assert_response :success
  end

  test "should get edit" do
    login(users(:admin))
    get :edit, id: @tool
    assert_response :success
  end

  test "should update tool" do
    login(users(:admin))
    patch :update, id: @tool, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: @tool.name, slug: @tool.slug, description: @tool.description }
    assert_redirected_to tool_path(assigns(:tool))
  end

  test "should destroy tool" do
    login(users(:admin))
    assert_difference('Tool.current.count', -1) do
      delete :destroy, id: @tool
    end

    assert_redirected_to tools_path
  end
end
