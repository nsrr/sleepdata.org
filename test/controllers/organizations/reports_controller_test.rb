# frozen_string_literal: true

require "test_helper"

# Tests to check that organization editors and viewers can see reports.
class Organizations::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @organization = organizations(:one)
  end

  test "should get data requests report" do
    login(@admin)
    get organizations_reports_data_requests_url(@organization)
    assert_response :success
  end

  test "should get data requests stats report" do
    login(@admin)
    get organizations_reports_data_request_stats_url(@organization)
    assert_response :success
  end

  test "should get this month report" do
    login(@admin)
    get organizations_reports_this_month_url(@organization)
    assert_response :success
  end
end
