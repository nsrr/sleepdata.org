# frozen_string_literal: true

require "test_helper"

# Tests to assure admins can create organizations.
class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @admin = users(:admin)
    @regular = users(:regular)
  end

  def organization_params
    {
      name: "New Organization",
      slug: "new-organization"
    }
  end

  test "should get new as admin" do
    login(@admin)
    get new_organization_url
    assert_response :success
  end

  test "should not get new as regular" do
    login(@regular)
    get new_organization_url
    assert_redirected_to root_url
  end

  test "should create organization as admin" do
    login(@admin)
    assert_difference("OrganizationUser.where(editor: true).count") do
      assert_difference("Organization.count") do
        post organizations_url, params: { organization: organization_params }
      end
    end
    assert_redirected_to organization_url(Organization.last)
  end

  test "should not create organization without name as admin" do
    login(@admin)
    assert_difference("Organization.count", 0) do
      post organizations_url, params: { organization: organization_params.merge(name: "") }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create organization as regular" do
    login(@regular)
    assert_difference("Organization.count", 0) do
      post organizations_url, params: { organization: organization_params }
    end
    assert_redirected_to root_url
  end

  test "should destroy organization as admin" do
    login(@admin)
    assert_difference("Organization.current.count", -1) do
      delete organization_url(@organization)
    end
    assert_redirected_to organizations_url
  end

  test "should not destroy organization as regular" do
    login(@regular)
    assert_difference("Organization.current.count", 0) do
      delete organization_url(@organization)
    end
    assert_redirected_to root_url
  end
end
