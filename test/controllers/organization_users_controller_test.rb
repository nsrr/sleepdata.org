# frozen_string_literal: true

require "test_helper"

# Test to assure users can be invited to be organization members.
class OrganizationUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @organization_user = organization_users(:one)
    @org_editor = users(:editor)
    @org_viewer = users(:orgone_viewer)
    @regular = users(:regular)
  end

  def organization_user_params
    {
      editor: "0",
      invite_email: "invite@example.com",
      review_role: "regular"
    }
  end

  test "should get index as public" do
    get organization_organization_users_url(@organization)
    assert_response :success
  end

  test "should get new as editor" do
    login(@org_editor)
    get new_organization_organization_user_url(@organization)
    assert_response :success
  end

  test "should create organization member as editor" do
    login(@org_editor)
    assert_difference("OrganizationUser.count") do
      post organization_organization_users_url(@organization), params: {
        organization_user: organization_user_params
      }
    end
    assert_redirected_to organization_organization_users_url(@organization)
  end

  test "should show organization member as editor" do
    login(@org_editor)
    get organization_organization_user_url(@organization, @organization_user)
    assert_response :success
  end

  test "should get edit as editor" do
    login(@org_editor)
    get edit_organization_organization_user_url(@organization, @organization_user)
    assert_response :success
  end

  test "should update organization member as editor" do
    login(@org_editor)
    patch organization_organization_user_url(@organization, @organization_user), params: {
      organization_user: organization_user_params
    }
    assert_redirected_to organization_organization_users_url(@organization)
  end

  test "should destroy organization member as editor" do
    login(@org_editor)
    assert_difference("OrganizationUser.count", -1) do
      delete organization_organization_user_url(@organization, @organization_user)
    end
    assert_redirected_to organization_organization_users_url(@organization)
  end

  test "should accept organization invitation after logging in" do
    login(users(:orgone_editor_invite))
    get invite_url(organization_users(:editor_invite).invite_token)
    assert_redirected_to accept_invite_url
    get accept_invite_url
    assert_equal users(:orgone_editor_invite), assigns(:organization_user).user
    assert_equal "Invite successfully accepted.", flash[:notice]
    assert_redirected_to assigns(:organization_user).organization
  end

  test "should accept organization invitation before logging in" do
    get invite_url(organization_users(:editor_invite).invite_token)
    assert_redirected_to new_user_session_url
    login(users(:orgone_editor_invite))
    assert_equal users(:orgone_editor_invite), assigns(:organization_user).user
    assert_equal "Invite successfully accepted.", flash[:notice]
    assert_redirected_to assigns(:organization_user).organization
  end
end
