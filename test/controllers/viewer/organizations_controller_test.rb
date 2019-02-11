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

  test "should get data requests submitted report as editor" do
    login(@org_editor)
    get data_requests_submitted_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests submitted report as viewer" do
    login(@org_viewer)
    get data_requests_submitted_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests submitted areport s regular" do
    login(@regular)
    get data_requests_submitted_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get data requests approved report as editor" do
    login(@org_editor)
    get data_requests_approved_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests approved report as viewer" do
    login(@org_viewer)
    get data_requests_approved_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests approved areport s regular" do
    login(@regular)
    get data_requests_approved_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get data requests total report as editor" do
    login(@org_editor)
    get data_requests_total_organization_url(@organization)
    assert_response :success
  end

  test "should get data requests total report as viewer" do
    login(@org_viewer)
    get data_requests_total_organization_url(@organization)
    assert_response :success
  end

  test "should not get data requests total areport s regular" do
    login(@regular)
    get data_requests_total_organization_url(@organization)
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

  test "should get data data requests year to date as editor" do
    login(@org_editor)
    get data_requests_year_to_date_organization_url(@organization)
    assert_response :success
  end

  test "should get data data requests year to date as viewer" do
    login(@org_viewer)
    get data_requests_year_to_date_organization_url(@organization)
    assert_response :success
  end

  test "should not get data data requests year to date as regular" do
    login(@regular)
    get data_requests_year_to_date_organization_url(@organization)
    assert_redirected_to organizations_url
  end

  test "should get data data requests since inception as editor" do
    login(@org_editor)
    get data_requests_since_inception_organization_url(@organization)
    assert_response :success
  end

  test "should get data data requests since inception as viewer" do
    login(@org_viewer)
    get data_requests_since_inception_organization_url(@organization)
    assert_response :success
  end

  test "should not get data data requests since inception as regular" do
    login(@regular)
    get data_requests_since_inception_organization_url(@organization)
    assert_redirected_to organizations_url
  end
end
