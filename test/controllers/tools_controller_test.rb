require 'test_helper'

class ToolsControllerTest < ActionController::TestCase
  setup do
    @tool = tools(:one)
  end

  test 'should get sync for editor' do
    login(users(:editor))
    get :sync, id: @tool
    assert_response :success
  end

  test 'should show requests to editor' do
    login(users(:editor))
    get :requests, id: @tool
    assert_response :success
  end

  test 'should request access to public tool' do
    login(users(:valid))
    assert_difference('ToolUser.count') do
      get :request_access, id: @tool
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
      get :request_access, id: @tool
    end

    assert_not_nil assigns(:tool_user)
    assert_equal nil, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:two), assigns(:tool_user).user

    assert_redirected_to submissions_path
  end

  test 'should approve access request to tool' do
    login(users(:editor))
    patch :set_access, id: @tool, tool_user_id: tool_users(:pending_public_access).id, approved: true, editor: false

    assert_not_nil assigns(:tool_user)
    assert_equal true, assigns(:tool_user).approved
    assert_equal false, assigns(:tool_user).editor
    assert_equal users(:two), assigns(:tool_user).user

    assert_redirected_to requests_tool_path(assigns(:tool), tool_user_id: assigns(:tool_user).id)
  end

  test 'should create access request to tool' do
    login(users(:editor))
    assert_difference('ToolUser.count') do
      post :create_access, id: @tool, user_id: users(:aug).id
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
      post :create_access, id: @tool, user_id: users(:two).id
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
      post :create, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: @tool.name, slug: 'new-tool', description: @tool.description }
    end

    assert_redirected_to tool_path(assigns(:tool))
  end

  test 'should not create tool with blank name' do
    login(users(:admin))
    assert_difference('Tool.count', 0) do
      post :create, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: '', slug: 'new-tool', description: @tool.description }
    end

    assert assigns(:tool).errors.size > 0
    assert_equal ["can't be blank"], assigns(:tool).errors[:name]

    assert_template 'new'
  end

  test 'should show tool' do
    get :show, id: @tool
    assert_response :success
  end

  test 'should get edit' do
    login(users(:admin))
    get :edit, id: @tool
    assert_response :success
  end

  test 'should update tool' do
    login(users(:admin))
    patch :update, id: @tool, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: @tool.name, slug: @tool.slug, description: @tool.description }
    assert_redirected_to tool_path(assigns(:tool))
  end

  test 'should not update tool with blank name' do
    login(users(:admin))
    patch :update, id: @tool, tool: { logo: fixture_file_upload('../../test/support/datasets/wecare/images/rails.png'), name: '', slug: @tool.slug, description: @tool.description }
    assert assigns(:tool).errors.size > 0
    assert_equal ["can't be blank"], assigns(:tool).errors[:name]

    assert_template 'edit'
  end

  test 'should destroy tool' do
    login(users(:admin))
    assert_difference('Tool.current.count', -1) do
      delete :destroy, id: @tool
    end

    assert_redirected_to tools_path
  end

  test 'should get logo from tool as anonymous user' do
    get :logo, id: @tool

    assert_not_nil response

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:tool).logo.url) ), response.body
  end

  test 'should show public page in subfolder to anonymous user' do
    # assert_difference('ToolPageAudit.count') do
      get :pages, id: @tool, path: 'subfolder/MORE_INFO.txt'
    # end
    assert_response :success
  end

  test 'should show public page in subfolder to logged in user' do
    login(users(:valid))
    # assert_difference('ToolPageAudit.count') do
      get :pages, id: @tool, path: 'subfolder/MORE_INFO.txt'
    # end
    assert_response :success
  end

  test 'should show directory of pages in subfolder' do
    get :pages, id: @tool, path: 'subfolder'
    assert_template 'pages'
    assert_response :success
  end

  test 'should not get non-existant page from public tool as anonymous user' do
    get :pages, id: @tool, path: 'subfolder/subsubfolder/3.md'
    assert_redirected_to pages_tool_path( assigns(:tool), path: 'subfolder' )
  end

  test 'should create page as editor' do
    login(users(:editor))
    post :create_page, id: @tool, page_name: 'CREATE_ME.md', page_contents: "# CREATE ME\nThis is the `CREATE_ME.md`."

    assert_redirected_to pages_tool_path(assigns(:tool), path: assigns(:path))

    # Clean up file so tests can be rerun
    file_path = Rails.root.join('test', 'support', 'tools', 'demo', 'pages', 'CREATE_ME.md')
    File.delete(file_path) if File.exist?(file_path)
  end

  test 'should not create page without a name as editor' do
    login(users(:admin)) # Should be :editor
    post :create_page, id: @tool, page_name: '', page_contents: 'Oh no, no name!'

    assert assigns(:errors).size > 0
    assert_equal "Page name can't be blank", assigns(:errors)[:page_name]

    assert_template 'new_page'
  end

  test 'should not create already existing page as editor' do
    login(users(:admin)) # Should be :editor
    post :create_page, id: @tool, page_name: 'VIEW_ME.md', page_contents: 'Oh no, it already exists!'

    assert assigns(:errors).size > 0
    assert_equal 'A page with that name already exists', assigns(:errors)[:page_name]

    assert_template 'new_page'
  end

  test 'should get edit_page as editor' do
    login(users(:admin)) # Should be :editor
    get :edit_page, id: @tool, path: 'EDIT_ME.md'
    assert_response :success
  end

  test 'should update_page as editor' do
    login(users(:admin)) # Should be :editor
    patch :update_page, id: @tool, path: 'EDIT_ME.md', page_contents: "# NEW TITLE\nThis is describing the tool using documentation.\n"
    assert_equal File.read(assigns(:tool).find_page('EDIT_ME.md')), "# NEW TITLE\nThis is describing the tool using documentation.\n"
    assert_redirected_to pages_tool_path(assigns(:tool), path: assigns(:path))
  end

  test 'should not get edit_page as editor of invalid page' do
    login(users(:admin)) # Should be :editor
    get :edit_page, id: @tool, path: 'wrongfolder/1.txt'
    assert_redirected_to pages_tool_path(assigns(:tool), path: assigns(:path))
  end
end
