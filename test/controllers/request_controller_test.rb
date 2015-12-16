require 'test_helper'

# This controller tests simultaneous registration and form submission
class RequestControllerTest < ActionController::TestCase
  test 'should get contribute tool start as public user' do
    get :contribute_tool_start
    assert_response :success
  end

  test 'should get contribute tool start as regular user' do
    login(users(:valid))
    get :contribute_tool_start
    assert_response :success
  end

  test 'should contribute tool and set location as public user' do
    post :contribute_tool_set_location, community_tool: { url: 'http://example.com' }
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_template :contribute_tool_about_me
    assert_response :success
  end

  test 'should contribute tool and set location as regular user' do
    login(users(:valid))
    assert_difference('CommunityTool.count') do
      post :contribute_tool_set_location, community_tool: { url: 'http://example.com' }
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test 'should not contribute tool with invalid url' do
    post :contribute_tool_set_location, community_tool: { url: 'not a url' }
    assert_not_nil assigns(:community_tool)
    assert_template :contribute_tool_start
    assert_response :success
  end

  test 'should contribute tool and register user as public user' do
    assert_difference('User.count') do
      assert_difference('CommunityTool.count') do
        post :contribute_tool_register_user, community_tool: { url: 'http://example.com' }, user: { first_name: 'First Name', last_name: 'Last Name', email: 'new_user@example.com' }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_equal 'new_user@example.com', assigns(:community_tool).user.email
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test 'should contribute tool and assign logged in regular user from registration page' do
    login(users(:valid))
    assert_difference('User.count', 0) do
      assert_difference('CommunityTool.count') do
        post :contribute_tool_register_user, community_tool: { url: 'http://example.com' }, user: { first_name: 'First Name', last_name: 'Last Name', email: 'new_user@example.com' }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test 'should not contribute tool and register user with existing email address' do
    assert_difference('User.count', 0) do
      assert_difference('CommunityTool.count', 0) do
        post :contribute_tool_register_user, community_tool: { url: 'http://example.com' }, user: { first_name: 'First Name', last_name: 'Last Name', email: 'valid@example.com' }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_not_nil assigns(:registration_errors)
    assert_template :contribute_tool_about_me
  end

  test 'should contribute tool and sign in user' do
    users(:valid).update password: 'password'
    assert_difference('User.count', 0) do
      assert_difference('CommunityTool.count') do
        patch :contribute_tool_sign_in_user, community_tool: { url: 'http://example.com' }, email: 'valid@example.com', password: 'password'
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test 'should contribute tool and assign logged in regular user from sign in page' do
    login(users(:valid))
    assert_difference('User.count', 0) do
      assert_difference('CommunityTool.count') do
        patch :contribute_tool_sign_in_user, community_tool: { url: 'http://example.com' }, email: '', password: ''
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test 'should not contribute tool and sign in user with invalid email and password' do
    assert_difference('User.count', 0) do
      assert_difference('CommunityTool.count', 0) do
        patch :contribute_tool_sign_in_user, community_tool: { url: 'http://example.com' }, email: 'valid@example.com', password: ''
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal 'http://example.com', assigns(:community_tool).url
    assert_not_nil assigns(:sign_in_errors)
    assert_template :contribute_tool_about_me
  end

  test 'should get contribute tool description as regular user' do
    login(users(:valid))
    get :contribute_tool_description, id: community_tools(:started)
    assert_response :success
  end

  test 'should not get contribute tool description as public user' do
    get :contribute_tool_description, id: community_tools(:started)
    assert_redirected_to new_user_session_path
  end

  test 'should not get contribute tool description as regular user with invalid id' do
    login(users(:valid))
    get :contribute_tool_description, id: -1
    assert_redirected_to dashboard_path
  end

  test 'should set description and submit tool as regular user' do
    login(users(:valid))
    post :contribute_tool_set_description, id: community_tools(:started), community_tool: { name: 'Tool Name', description: 'Tool Description' }
    assert_not_nil assigns(:community_tool)
    assert_equal 'Tool Name', assigns(:community_tool).name
    assert_equal 'Tool Description', assigns(:community_tool).description
    assert_redirected_to contribute_tool_submitted_path
  end

  test 'should set description and save draft tool as regular user' do
    login(users(:valid))
    post :contribute_tool_set_description, id: community_tools(:started), community_tool: { name: 'Tool Name - DRAFT', description: '' }, draft: '1'
    assert_not_nil assigns(:community_tool)
    assert_equal 'Tool Name - DRAFT', assigns(:community_tool).name
    assert_equal '', assigns(:community_tool).description
    assert_redirected_to dashboard_path
  end

  test 'should not set description and submit tool as regular user with invalid id' do
    login(users(:valid))
    post :contribute_tool_set_description, id: -1, community_tool: { name: 'Tool Name', description: 'Tool Description' }
    assert_nil assigns(:community_tool)
    assert_redirected_to dashboard_path
  end

  test 'should not submit tool as regular user without description' do
    login(users(:valid))
    post :contribute_tool_set_description, id: community_tools(:started), community_tool: { name: '', description: '' }
    assert_not_nil assigns(:community_tool)
    assert assigns(:community_tool).errors.size > 0
    assert_equal ["can't be blank"], assigns(:community_tool).errors[:name]
    assert_equal ["can't be blank"], assigns(:community_tool).errors[:description]
    assert_template :contribute_tool_description
    assert_response :success
  end

  test 'should not set description and submit tool as public user' do
    post :contribute_tool_set_description, id: community_tools(:started), community_tool: { name: 'Tool Name', description: 'Tool Description' }
    assert_nil assigns(:community_tool)
    assert_redirected_to new_user_session_path
  end

  test 'should get tool request' do
    get :tool_request
    assert_response :success
  end

  test 'should get dataset hosting' do
    get :dataset_hosting
    assert_response :success
  end

  test 'should create dataset hosting request for new user' do
    assert_difference('User.count') do
      assert_difference('HostingRequest.count') do
        post :create_hosting_request, user: { first_name: 'First Name', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end
    assert_redirected_to dataset_hosting_submitted_path
  end

  test 'should create dataset hosting request for logged in user' do
    login(users(:valid))
    assert_difference('User.count', 0) do
      assert_difference('HostingRequest.count') do
        post :create_hosting_request, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end
    assert_redirected_to dataset_hosting_submitted_path
  end

  test 'should not create dataset hosting request for new user with incomplete information' do
    assert_difference('User.count', 0) do
      assert_difference('HostingRequest.count', 0) do
        post :create_hosting_request, user: { first_name: '', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: 'Description', institution_name: 'Institution' }
      end
    end

    assert_not_nil assigns(:errors)
    assert_equal ["can't be blank"], assigns(:errors)[:first_name]

    assert_template :dataset_hosting
    assert_response :success
  end

  test 'should register user but not create dataset hosting request with incomplete information' do
    assert_difference('User.count', 1) do
      assert_difference('HostingRequest.count', 0) do
        post :create_hosting_request, user: { first_name: 'First Name', last_name: 'Last Name', email: 'dataset@hosting.com' }, hosting_request: { description: '', institution_name: 'Institution' }
      end
    end

    assert_not_nil assigns(:hosting_request)
    assert assigns(:hosting_request).errors.size > 0
    assert_equal ["can't be blank"], assigns(:hosting_request).errors[:description]

    assert_template :dataset_hosting
    assert_response :success
  end

  test 'should get dataset hosting submitted' do
    get :dataset_hosting_submitted
    assert_response :success
  end
end
