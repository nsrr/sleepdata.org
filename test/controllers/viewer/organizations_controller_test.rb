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

  test "should get reports as editor" do
    login(@org_editor)
    get reports_organization_url(@organization)
    assert_response :success
  end

  test "should get reports as viewer" do
    login(@org_viewer)
    get reports_organization_url(@organization)
    assert_response :success
  end

  test "should not get reports as regular" do
    login(@regular)
    get reports_organization_url(@organization)
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

  test "should get data requests stats report as editor" do
    login(@org_editor)
    get data_request_stats_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests stats report as viewer" do
    login(@org_viewer)
    get data_request_stats_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests stats report as regular" do
    login(@regular)
    get data_request_stats_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get this month report as editor" do
    login(@org_editor)
    get this_month_organization_url(@organization)
    assert_response :success
  end

  test "should get this month report as viewer" do
    login(@org_viewer)
    get this_month_organization_url(@organization)
    assert_response :success
  end

  test "should not get this month report as regular" do
    login(@regular)
    get this_month_organization_url(@organization)
    assert_redirected_to organizations_url
  end
end
