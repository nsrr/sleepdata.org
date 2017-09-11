# frozen_string_literal: true

require "test_helper"

# Allows admins to create organizations and assign users as owners.
class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @admin = users(:admin)
  end

  def organization_params
    {
      name: "New Organization",
      slug: "new-organization"
    }
  end

  test "should get index" do
    login(@admin)
    get organizations_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_organization_url
    assert_response :success
  end

  test "should create organization" do
    login(@admin)
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: organization_params }
    end
    assert_redirected_to organization_url(Organization.last)
  end

  test "should not create organization without name" do
    login(@admin)
    assert_difference("Organization.count", 0) do
      post organizations_url, params: { organization: organization_params.merge(name: "") }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show organization" do
    login(@admin)
    get organization_url(@organization)
    assert_response :success
  end

  test "should show organization datasets" do
    login(@admin)
    get datasets_organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    login(@admin)
    patch organization_url(@organization), params: {
      organization: organization_params.merge(name: "Updated Organization", slug: "updated-organization")
    }
    assert_redirected_to organization_url("updated-organization")
  end

  test "should not update organization with blank name" do
    login(@admin)
    patch organization_url(@organization), params: {
      id: @organization, organization: organization_params.merge(name: "", slug: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy organization" do
    login(@admin)
    assert_difference("Organization.current.count", -1) do
      delete organization_url(@organization)
    end
    assert_redirected_to organizations_url
  end
end
