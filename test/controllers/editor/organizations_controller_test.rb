# frozen_string_literal: true

require "test_helper"

# Tests to check that organization editors can view settings.
class Editor::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @org_editor = users(:editor)
    @org_viewer = users(:orgone_viewer)
    @regular = users(:regular)
  end

  def organization_params
    {
      name: "New Organization",
      slug: "new-organization"
    }
  end

  test "should get settings as editor" do
    login(@org_editor)
    get settings_organization_url(@organization)
    assert_response :success
  end

  test "should not get settings as viewer" do
    login(@org_viewer)
    get settings_organization_url(@organization)
    assert_redirected_to organization_url(@organization)
  end

  test "should not get settings as regular" do
    login(@regular)
    get settings_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get edit as editor" do
    login(@org_editor)
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should not get edit as viewer" do
    login(@org_viewer)
    get edit_organization_url(@organization)
    assert_redirected_to organization_url(@organization)
  end

  test "should not get edit as regular" do
    login(@regular)
    get edit_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should update organization as editor" do
    login(@org_editor)
    patch organization_url(@organization), params: {
      organization: organization_params.merge(name: "Updated Organization", slug: "updated-organization")
    }
    assert_redirected_to settings_organization_url("updated-organization")
  end

  test "should not update organization with blank name as editor" do
    login(@org_editor)
    patch organization_url(@organization), params: {
      id: @organization, organization: organization_params.merge(name: "", slug: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update organization as viewer" do
    login(@org_viewer)
    patch organization_url(@organization), params: {
      organization: organization_params.merge(name: "Updated Organization", slug: "updated-organization")
    }
    assert_redirected_to organization_url("organization-one")
  end

  test "should not update organization as regular" do
    login(@regular)
    patch organization_url(@organization), params: {
      organization: organization_params.merge(name: "Updated Organization", slug: "updated-organization")
    }
    assert_redirected_to organizations_url
  end
end
