# frozen_string_literal: true

require "test_helper"

# This controller tests simultaneous registration and form submission.
class RequestControllerTest < ActionDispatch::IntegrationTest
  test "should get contribute tool start as public user" do
    get contribute_tool_start_url
    assert_response :success
  end

  test "should get contribute tool start as regular user" do
    login(users(:valid))
    get contribute_tool_start_url
    assert_response :success
  end

  test "should contribute tool and set location as public user" do
    post contribute_tool_set_location_url, params: { tool: { url: "http://example.com" } }
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_template :contribute_tool_about_me
    assert_response :success
  end

  test "should contribute tool and set location as regular user" do
    login(users(:valid))
    assert_difference("Tool.count") do
      post contribute_tool_set_location_url, params: { tool: { url: "http://example.com" } }
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_equal users(:valid), assigns(:tool).user
    assert_redirected_to contribute_tool_description_url(assigns(:tool))
  end

  test "should not contribute tool with invalid url" do
    post contribute_tool_set_location_url, params: { tool: { url: "not a url" } }
    assert_not_nil assigns(:tool)
    assert_template :contribute_tool_start
    assert_response :success
  end

  test "should contribute tool and register user as public user" do
    skip
    assert_difference("User.count") do
      assert_difference("Tool.count") do
        post contribute_tool_register_user_url, params: { tool: { url: "http://example.com" }, user: { username: "newuser", email: "newuser@example.com" } }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_equal "newuser@example.com", assigns(:tool).user.email
    assert_redirected_to contribute_tool_description_url(assigns(:tool))
  end

  test "should contribute tool and assign logged in regular user from registration page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("Tool.count") do
        post contribute_tool_register_user_url, params: { tool: { url: "http://example.com" }, user: { username: "newuser", email: "newuser@example.com" } }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_equal users(:valid), assigns(:tool).user
    assert_redirected_to contribute_tool_description_url(assigns(:tool))
  end

  test "should not contribute tool and register user with existing email address" do
    skip
    assert_difference("User.count", 0) do
      assert_difference("Tool.count", 0) do
        post contribute_tool_register_user_url, params: {
          tool: { url: "http://example.com" },
          user: { username: "duplicateaccount", email: "valid@example.com" }
        }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_not_nil assigns(:registration_errors)
    assert_template :contribute_tool_about_me
  end

  test "should contribute tool and sign in user" do
    users(:valid).update password: "password"
    assert_difference("User.count", 0) do
      assert_difference("Tool.count") do
        patch contribute_tool_sign_in_user_url, params: {
          tool: { url: "http://example.com" },
          email: "valid@example.com", password: "password"
        }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_equal users(:valid), assigns(:tool).user
    assert_redirected_to contribute_tool_description_url(assigns(:tool))
  end

  test "should contribute tool and assign logged in regular user from sign in page" do
    login(users(:valid))
    assert_difference("User.count", 0) do
      assert_difference("Tool.count") do
        patch contribute_tool_sign_in_user_url, params: {
          tool: { url: "http://example.com" }, email: "", password: ""
        }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_equal users(:valid), assigns(:tool).user
    assert_redirected_to contribute_tool_description_url(assigns(:tool))
  end

  test "should not contribute tool and sign in user with invalid email and password" do
    assert_difference("User.count", 0) do
      assert_difference("Tool.count", 0) do
        patch contribute_tool_sign_in_user_url, params: {
          tool: { url: "http://example.com" },
          email: "valid@example.com", password: ""
        }
      end
    end
    assert_not_nil assigns(:tool)
    assert_equal "http://example.com", assigns(:tool).url
    assert_not_nil assigns(:sign_in_errors)
    assert_template :contribute_tool_about_me
  end

  test "should get contribute tool description as regular user" do
    login(users(:valid))
    get contribute_tool_description_url(tools(:draft))
    assert_response :success
  end

  test "should not get contribute tool description as public user" do
    get contribute_tool_description_url(tools(:draft))
    assert_redirected_to new_user_session_url
  end

  test "should not get contribute tool description as regular user with invalid id" do
    login(users(:valid))
    get contribute_tool_description_url(-1)
    assert_redirected_to dashboard_url
  end

  test "should set description and publish tool as regular user" do
    login(users(:valid))
    post contribute_tool_set_description_url(tools(:draft)), params: {
      tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_not_nil assigns(:tool)
    assert_equal "Tool Name", assigns(:tool).name
    assert_equal "Tool Description", assigns(:tool).description
    assert_equal true, assigns(:tool).published?
    assert_equal Time.zone.today, assigns(:tool).publish_date
    assert_redirected_to tool_url(tools(:draft))
  end

  test "should set description and save draft tool as regular user" do
    login(users(:valid))
    post contribute_tool_set_description_url(tools(:draft)), params: {
      tool: { name: "Tool Name - DRAFT", description: "" },
      draft: "1"
    }
    assert_not_nil assigns(:tool)
    assert_equal "Tool Name - DRAFT", assigns(:tool).name
    assert_equal "", assigns(:tool).description
    assert_equal false, assigns(:tool).published?
    assert_nil assigns(:tool).publish_date
    assert_redirected_to tool_url(tools(:draft))
  end

  test "should not set description and submit tool as regular user with invalid id" do
    login(users(:valid))
    post contribute_tool_set_description_url(-1), params: {
      tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_nil assigns(:tool)
    assert_redirected_to dashboard_url
  end

  test "should not submit tool as regular user without description" do
    login(users(:valid))
    post contribute_tool_set_description_url(tools(:draft)), params: {
      tool: { name: "", description: "" }
    }
    assert_not_nil assigns(:tool)
    assert_equal ["can't be blank"], assigns(:tool).errors[:name]
    assert_equal ["can't be blank"], assigns(:tool).errors[:description]
    assert_template :contribute_tool_description
    assert_response :success
  end

  test "should not set description and submit tool as public user" do
    post contribute_tool_set_description_url(tools(:draft)), params: {
      tool: { name: "Tool Name", description: "Tool Description" }
    }
    assert_redirected_to new_user_session_url
  end

  test "should get tool request" do
    get tool_request_url
    assert_response :success
  end
end
