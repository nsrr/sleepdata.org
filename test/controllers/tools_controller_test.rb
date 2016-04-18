# frozen_string_literal: true

require 'test_helper'

class ToolsControllerTest < ActionController::TestCase
  setup do
    @tool = tools(:one)
  end

  def tool_params
    {
      name: @tool.name,
      slug: @tool.slug,
      description: @tool.description,
      logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png')
    }
  end

  test 'should get sync for editor' do
    login(users(:editor))
    get :sync, params: { id: @tool }
    assert_response :success
  end

  test 'should get pull changes for editor' do
    login(users(:editor))
    post :pull_changes, params: { id: @tool }
    assert_redirected_to sync_tool_path(@tool)
  end

  test 'should show requests to editor' do
    login(users(:editor))
    get :requests, params: { id: @tool }
    assert_response :success
  end

  test 'should request access to public tool' do
    login(users(:valid))
    assert_difference('ToolUser.count') do
      get :request_access, params: { id: @tool }
    end

    assert_not_nil assigns(:tool_user)
    assert_equal nil, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:valid), assigns(:tool_user).user

    assert_redirected_to submissions_path
  end

  test 'should not create additional requests with existing request' do
    login(users(:two))
    assert_difference('ToolUser.count', 0) do
      get :request_access, params: { id: @tool }
    end

    assert_not_nil assigns(:tool_user)
    assert_equal nil, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:two), assigns(:tool_user).user

    assert_redirected_to submissions_path
  end

  test 'should approve access request to tool' do
    login(users(:editor))
    patch :set_access, params: { id: @tool, tool_user_id: tool_users(:pending_public_access).id, approved: true, editor: false }

    assert_not_nil assigns(:tool_user)
    assert_equal true, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:two), assigns(:tool_user).user

    assert_redirected_to requests_tool_path(assigns(:tool), tool_user_id: assigns(:tool_user).id)
  end

  test 'should create access request to tool' do
    login(users(:editor))
    assert_difference('ToolUser.count') do
      post :create_access, params: { id: @tool, user_id: users(:aug).id }
    end

    assert_not_nil assigns(:tool_user)
    assert_equal nil, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:aug), assigns(:tool_user).user

    assert_redirected_to requests_tool_path(assigns(:tool), tool_user_id: assigns(:tool_user).id)
  end

  test 'should find existing access when creating access request to tool' do
    login(users(:editor))
    assert_difference('ToolUser.count', 0) do
      post :create_access, params: { id: @tool, user_id: users(:two).id }
    end

    assert_not_nil assigns(:tool_user)
    assert_equal nil, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:two), assigns(:tool_user).user

    assert_redirected_to requests_tool_path(assigns(:tool), tool_user_id: assigns(:tool_user).id)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:tools)
  end

  test 'should get new' do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test 'should create tool' do
    login(users(:admin))
    assert_difference('Tool.count') do
      post :create, params: { tool: tool_params.merge(slug: 'new-tool') }
    end

    assert_redirected_to tool_path(assigns(:tool))
  end

  test 'should not create tool with blank name' do
    login(users(:admin))
    assert_difference('Tool.count', 0) do
      post :create, params: {
        tool: tool_params.merge(name: '', slug: 'new-tool')
      }
    end
    assert assigns(:tool).errors.size > 0
    assert_equal ["can't be blank"], assigns(:tool).errors[:name]
    assert_template 'new'
    assert_response :success
  end

  test 'should show tool' do
    get :show, params: { id: @tool }
    assert_response :success
  end

  test 'should get edit' do
    login(users(:admin))
    get :edit, params: { id: @tool }
    assert_response :success
  end

  test 'should update tool' do
    login(users(:admin))
    patch :update, params: { id: @tool, tool: tool_params }
    assert_redirected_to tool_path(assigns(:tool))
  end

  test 'should not update tool with blank name' do
    # TODO: This test is failing in Rails 5 when a blank name is passed.
    # Something is happening here with strong params and validations
    # This is related to:
    # https://github.com/rails/rails/issues/23997
    # and
    # https://github.com/rack/rack/pull/1029
    # Should be fixed when rack beyond 2.0.0.alpha is released
    login(users(:admin))
    patch :update, params: { id: @tool, tool: tool_params.merge(name: '') }
    assert assigns(:tool).errors.size > 0
    assert_equal ["can't be blank"], assigns(:tool).errors[:name]
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy tool' do
    login(users(:admin))
    assert_difference('Tool.current.count', -1) do
      delete :destroy, params: { id: @tool }
    end

    assert_redirected_to tools_path
  end

  test 'should get logo from tool as anonymous user' do
    get :logo, params: { id: @tool }

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:tool).logo.url) ), response.body
  end

  test 'should show public page in subfolder to anonymous user' do
    # assert_difference('ToolPageAudit.count') do
      get :pages, params: { id: @tool, path: 'subfolder/MORE_INFO.txt', format: 'html' }
    # end
    assert_response :success
  end

  test 'should show public page in subfolder to logged in user' do
    login(users(:valid))
    # assert_difference('ToolPageAudit.count') do
      get :pages, params: { id: @tool, path: 'subfolder/MORE_INFO.txt', format: 'html' }
    # end
    assert_response :success
  end

  test 'should show directory of pages in subfolder' do
    get :pages, params: { id: @tool, path: 'subfolder', format: 'html' }
    assert_template 'pages'
    assert_response :success
  end

  test 'should not get non-existant page from public tool as anonymous user' do
    get :pages, params: { id: @tool, path: 'subfolder/subsubfolder/3.md', format: 'html' }
    assert_redirected_to pages_tool_path( assigns(:tool), path: 'subfolder' )
  end
end
