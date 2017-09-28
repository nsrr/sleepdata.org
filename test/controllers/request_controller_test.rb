# frozen_string_literal: true

require "test_helper"

# This controller tests simultaneous registration and form submission.
class RequestControllerTest < ActionController::TestCase
  test "should get contribute tool start as public user" do
    get :contribute_tool_start
    assert_response :success
  end

  test "should get contribute tool start as regular user" do
    login(users(:valid))
    get :contribute_tool_start
    assert_response :success
  end

  test "should contribute tool and set location as public user" do
    post :contribute_tool_set_location, params: { community_tool: { url: "http://example.com" } }
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_template :contribute_tool_about_me
    assert_response :success
  end

  test "should contribute tool and set location as regular user" do
    login(users(:valid))
    assert_difference("CommunityTool.count") do
      post :contribute_tool_set_location, params: { community_tool: { url: "http://example.com" } }
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test "should not contribute tool with invalid url" do
    post :contribute_tool_set_location, params: { community_tool: { url: "not a url" } }
    assert_not_nil assigns(:community_tool)
    assert_template :contribute_tool_start
    assert_response :success
  end

  test "should contribute tool and register user as public user" do
    assert_difference("User.count") do
      assert_difference("CommunityTool.count") do
        post :contribute_tool_register_user, params: { community_tool: { url: "http://example.com" }, user: { first_name: "First Name", last_name: "Last Name", email: "new_user@example.com" } }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_equal "new_user@example.com", assigns(:community_tool).user.email
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test "should contribute tool and assign logged in regular user from registration page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("CommunityTool.count") do
        post :contribute_tool_register_user, params: { community_tool: { url: "http://example.com" }, user: { first_name: "First Name", last_name: "Last Name", email: "new_user@example.com" } }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test "should not contribute tool and register user with existing email address" do
    assert_difference("User.count", 0) do
      assert_difference("CommunityTool.count", 0) do
        post :contribute_tool_register_user, params: {
          community_tool: { url: "http://example.com" },
          user: { first_name: "First Name", last_name: "Last Name", email: "valid@example.com" }
        }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_not_nil assigns(:registration_errors)
    assert_template :contribute_tool_about_me
  end

  test "should contribute tool and sign in user" do
    users(:valid).update password: "password"
    assert_difference("User.count", 0) do
      assert_difference("CommunityTool.count") do
        patch :contribute_tool_sign_in_user, params: {
          community_tool: { url: "http://example.com" },
          email: "valid@example.com", password: "password"
        }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test "should contribute tool and assign logged in regular user from sign in page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("CommunityTool.count") do
        patch :contribute_tool_sign_in_user, params: {
          community_tool: { url: "http://example.com" }, email: "", password: ""
        }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_equal users(:valid), assigns(:community_tool).user
    assert_redirected_to contribute_tool_description_path(assigns(:community_tool))
  end

  test "should not contribute tool and sign in user with invalid email and password" do
    assert_difference("User.count", 0) do
      assert_difference("CommunityTool.count", 0) do
        patch :contribute_tool_sign_in_user, params: {
          community_tool: { url: "http://example.com" },
          email: "valid@example.com", password: ""
        }
      end
    end
    assert_not_nil assigns(:community_tool)
    assert_equal "http://example.com", assigns(:community_tool).url
    assert_not_nil assigns(:sign_in_errors)
    assert_template :contribute_tool_about_me
  end

  test "should get contribute tool description as regular user" do
    login(users(:valid))
    get :contribute_tool_description, params: { id: community_tools(:draft) }
    assert_response :success
  end

  test "should not get contribute tool description as public user" do
    get :contribute_tool_description, params: { id: community_tools(:draft) }
    assert_redirected_to new_user_session_path
  end

  test "should not get contribute tool description as regular user with invalid id" do
    login(users(:valid))
    get :contribute_tool_description, params: { id: -1 }
    assert_redirected_to dashboard_path
  end

  test "should set description and publish tool as regular user" do
    login(users(:valid))
    post :contribute_tool_set_description, params: {
      id: community_tools(:draft),
      community_tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_not_nil assigns(:community_tool)
    assert_equal "Tool Name", assigns(:community_tool).name
    assert_equal "Tool Description", assigns(:community_tool).description
    assert_equal true, assigns(:community_tool).published?
    assert_equal Time.zone.today, assigns(:community_tool).publish_date
    assert_redirected_to community_show_tool_path(community_tools(:draft))
  end

  test "should set description and save draft tool as regular user" do
    login(users(:valid))
    post :contribute_tool_set_description, params: {
      id: community_tools(:draft),
      community_tool: { name: "Tool Name - DRAFT", description: "" },
      draft: "1"
    }
    assert_not_nil assigns(:community_tool)
    assert_equal "Tool Name - DRAFT", assigns(:community_tool).name
    assert_equal "", assigns(:community_tool).description
    assert_equal false, assigns(:community_tool).published?
    assert_nil assigns(:community_tool).publish_date
    assert_redirected_to dashboard_path
  end

  test "should not set description and submit tool as regular user with invalid id" do
    login(users(:valid))
    post :contribute_tool_set_description, params: {
      id: -1,
      community_tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_nil assigns(:community_tool)
    assert_redirected_to dashboard_path
  end

  test "should not submit tool as regular user without description" do
    login(users(:valid))
    post :contribute_tool_set_description, params: {
      id: community_tools(:draft), community_tool: { name: "", description: "" }
    }
    assert_not_nil assigns(:community_tool)
    assert_equal ["can't be blank"], assigns(:community_tool).errors[:name]
    assert_equal ["can't be blank"], assigns(:community_tool).errors[:description]
    assert_template :contribute_tool_description
    assert_response :success
  end

  test "should not set description and submit tool as public user" do
    post :contribute_tool_set_description, params: {
      id: community_tools(:draft),
      community_tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_nil assigns(:community_tool)
    assert_redirected_to new_user_session_path
  end

  test "should get submissions start as public user" do
    get :submissions_start, params: { dataset: "wecare" }
    assert_response :success
  end

  test "should get submissions start as regular user" do
    login(users(:valid))
    get :submissions_start, params: { dataset: "wecare" }
    assert_response :success
  end

  test "should get tool request" do
    get :tool_request
    assert_response :success
  end

  test "should get dataset hosting start as public user" do
    get :dataset_hosting_start
    assert_response :success
  end

  test "should get dataset hosting start as regular user" do
    login(users(:valid))
    get :dataset_hosting_start
    assert_response :success
  end

  test "should dataset hosting and set description as public user" do
    post :dataset_hosting_set_description, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" } }
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_template :dataset_hosting_about_me
    assert_response :success
  end

  test "should dataset hosting and set description as regular user" do
    login(users(:valid))
    assert_difference("HostingRequest.count") do
      post :dataset_hosting_set_description, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" } }
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_equal users(:valid), assigns(:hosting_request).user
    assert_redirected_to dataset_hosting_submitted_path
  end

  test "should not dataset hosting with blank description" do
    post :dataset_hosting_set_description, params: { hosting_request: { description: "", institution_name: "Institution Name" } }
    assert_not_nil assigns(:hosting_request)
    assert_template :dataset_hosting_start
    assert_response :success
  end

  test "should dataset hosting and register user as public user" do
    assert_difference("User.count") do
      assert_difference("HostingRequest.count") do
        post :dataset_hosting_register_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, user: { first_name: "First Name", last_name: "Last Name", email: "new_user@example.com" } }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_equal "new_user@example.com", assigns(:hosting_request).user.email
    assert_redirected_to dataset_hosting_submitted_path
  end

  test "should dataset hosting and assign logged in regular user from registration page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("HostingRequest.count") do
        post :dataset_hosting_register_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, user: { first_name: "First Name", last_name: "Last Name", email: "new_user@example.com" } }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_equal users(:valid), assigns(:hosting_request).user
    assert_redirected_to dataset_hosting_submitted_path
  end

  test "should not dataset hosting and register user with existing email address" do
    assert_difference("User.count", 0) do
      assert_difference("HostingRequest.count", 0) do
        post :dataset_hosting_register_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, user: { first_name: "First Name", last_name: "Last Name", email: "valid@example.com" } }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_not_nil assigns(:registration_errors)
    assert_template :dataset_hosting_about_me
  end

  test "should dataset hosting and sign in user" do
    users(:valid).update password: "password"
    assert_difference("User.count", 0) do
      assert_difference("HostingRequest.count") do
        patch :dataset_hosting_sign_in_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, email: "valid@example.com", password: "password" }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_equal users(:valid), assigns(:hosting_request).user
    assert_redirected_to dataset_hosting_submitted_path
  end

  test "should dataset hosting and assign logged in regular user from sign in page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("HostingRequest.count") do
        patch :dataset_hosting_sign_in_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, email: "", password: "" }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_equal users(:valid), assigns(:hosting_request).user
    assert_redirected_to dataset_hosting_submitted_path
  end

  test "should not dataset hosting and sign in user with invalid email and password" do
    assert_difference("User.count", 0) do
      assert_difference("HostingRequest.count", 0) do
        patch :dataset_hosting_sign_in_user, params: { hosting_request: { description: "Dataset is a set of EDFs", institution_name: "Institution Name" }, email: "valid@example.com", password: "" }
      end
    end
    assert_not_nil assigns(:hosting_request)
    assert_equal "Dataset is a set of EDFs", assigns(:hosting_request).description
    assert_equal "Institution Name", assigns(:hosting_request).institution_name
    assert_not_nil assigns(:sign_in_errors)
    assert_template :dataset_hosting_about_me
  end

  # test "should get dataset hosting description as regular user" do
  #   login(users(:valid))
  #   get :dataset_hosting_description, params: { id: hosting_requests(:started) }
  #   assert_response :success
  # end

  # test "should not get dataset hosting description as public user" do
  #   get :dataset_hosting_description, params: { id: hosting_requests(:started) }
  #   assert_redirected_to new_user_session_path
  # end

  # test "should not get dataset hosting description as regular user with invalid id" do
  #   login(users(:valid))
  #   get :dataset_hosting_description, params: { id: -1 }
  #   assert_redirected_to dashboard_path
  # end

  test "should get dataset hosting submitted as regular user" do
    login(users(:valid))
    get :dataset_hosting_submitted
    assert_response :success
  end

  test "should launch a new submission as a regular user" do
    skip # TODO: Make test use new DAUA submission process.
    login(users(:contributor))
    post :submissions_launch, params: { dataset: datasets(:released) }
    assert_equal "started", assigns(:agreement).status
    assert_equal [datasets(:released)], assigns(:agreement).datasets.to_a
    assert_redirected_to step_agreement_path(assigns(:agreement), step: assigns(:agreement).current_step)
  end
end
