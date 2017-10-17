# frozen_string_literal: true

require "test_helper"

# Test data access request process.
class DataRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @released = datasets(:released)
    @started = agreements(:started)
  end

  test "should get start" do
    skip # TODO: Make start redirect to correct legal document based on user selections.
    login(@regular)
    get data_requests_start_url(@released)
    assert_response :success
  end

  test "should get request as individual or organization" do
    login(@regular)
    get data_requests_request_as_individual_or_organization_url(@released)
    assert_response :success
  end

  test "should update request as individual" do
    login(@regular)
    post data_requests_update_individual_or_organization_url(@released, data_user_type: "individual")
    @regular.reload
    assert_equal "individual", @regular.data_user_type
    assert_redirected_to data_requests_start_url(@released)
  end

  test "should update request as organization" do
    login(@regular)
    post data_requests_update_individual_or_organization_url(@released, data_user_type: "organization")
    @regular.reload
    assert_equal "organization", @regular.data_user_type
    assert_redirected_to data_requests_start_url(@released)
  end

  test "should get intended use noncommercial or commercial" do
    login(@regular)
    get data_requests_intended_use_noncommercial_or_commercial_url(@released)
    assert_response :success
  end

  test "should update intended use noncommercial" do
    login(@regular)
    post data_requests_update_noncommercial_or_commercial_url(@released, commercial_type: "noncommercial")
    @regular.reload
    assert_equal "noncommercial", @regular.commercial_type
    assert_redirected_to data_requests_start_url(@released)
  end

  test "should update intended use commercial" do
    login(@regular)
    post data_requests_update_noncommercial_or_commercial_url(@released, commercial_type: "commercial")
    @regular.reload
    assert_equal "commercial", @regular.commercial_type
    assert_redirected_to data_requests_start_url(@released)
  end

  test "should get page" do
    login(@regular)
    get data_requests_page_url(@started, page: "1")
    assert_response :success
  end

  # TODO: Add more variables on page 2.
  test "should update page" do
    login(@regular)
    post data_requests_update_page_url(@started, "1", full_name: "Regular User")
    assert_equal(
      "Regular User",
      @started.agreement_variables.find_by(
        final_legal_document_variable: final_legal_document_variables(:full_name)
      ).value
    )
    assert_redirected_to data_requests_page_url(@started, "2")
  end

  test "should get attest" do
    login(@regular)
    get data_requests_attest_url(@started)
    assert_response :success
  end

  test "should update attest with checkbox" do
    skip
    login(@regular)
    post data_requests_update_attest_url(@started) # TODO: Add checkbox params.
    # assert_equal # TODO: Assert checked and timestamp.
    assert_redirected_to data_requests_proof_url(@started, "2")
  end

  test "should update attest with signature" do
    skip
    login(@regular)
    post data_requests_update_attest_url(@started, data_uri: "") # TODO: Add signature params.
    # assert_equal # TODO: Assert signature and timestamp.
    assert_redirected_to data_requests_proof_url(@started, "2")
  end

  test "should get addendum" do
    login(@regular)
    get data_requests_addendum_url(@started, "1")
    assert_response :success
  end

  test "should get addons" do
    login(@regular)
    get data_requests_addons_url(@started)
    assert_response :success
  end

  test "should get proof" do
    login(@regular)
    get data_requests_proof_url(@started)
    assert_response :success
  end

  test "should get submitted" do
    login(@regular)
    get data_requests_submitted_url(@started)
    assert_response :success
  end

  test "should get print" do
    login(@regular)
    get data_requests_print_url(@started)
    assert_response :success
  end
end
