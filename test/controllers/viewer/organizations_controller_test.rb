# frozen_string_literal: true

require "test_helper"

# Tests to check that organization editors and viewers can see reports.
class Viewer::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @org_editor = users(:editor)
    @org_viewer = users(:orgone_viewer)
    @regular = users(:regular)
  end

  test "should get data requests as editor" do
    login(@org_editor)
    get data_requests_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests as viewer" do
    login(@org_viewer)
    get data_requests_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests as regular" do
    login(@regular)
    get data_requests_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get data requests report as editor" do
    login(@org_editor)
    get data_requests_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests report as viewer" do
    login(@org_viewer)
    get data_requests_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests report as regular" do
    login(@regular)
    get data_requests_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get data requests with dataset report as editor" do
    login(@org_editor)
    get data_requests_organization_url(@organization, dataset: datasets(:released))
    assert_response :success
  end

  test "should get data requests with dataset report as viewer" do
    login(@org_viewer)
    get data_requests_organization_url(@organization, dataset: datasets(:released))
    assert_response :success
  end

  test "should not get data requests with dataset report as regular" do
    login(@regular)
    get data_requests_organization_url(@organization, dataset: datasets(:released))
    assert_redirected_to organizations_url
  end

  test "should get data downloads as editor" do
    login(@org_editor)
    get data_downloads_organization_url(@organization)
    assert_response :success
  end

  test "should get data downloads as viewer" do
    login(@org_viewer)
    get data_downloads_organization_url(@organization)
    assert_response :success
  end

  test "should not get data downloads as regular" do
    login(@regular)
    get data_downloads_organization_url(@organization)
    assert_redirected_to organizations_url
  end
end
