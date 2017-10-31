# frozen_string_literal: true

require "test_helper"

# Test data access request process.
class DataRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @orgtwo_regular = users(:orgtwo_regular)
    @orgthree_regular = users(:orgthree_regular)
    @released = datasets(:released)
    @started = agreements(:started)
    @checkbox_attestestation_started = agreements(:checkbox_attestestation_started)
    @simple_started = agreements(:simple_started)
  end

  test "should get start for simple legal document" do
    login(users(:orgthree_regular_no_data_requests))
    get data_requests_start_url(datasets(:orgthree_crowd))
    assert_response :success
  end

  test "should get start and redirect for existing data request legal document without pages" do
    login(@orgthree_regular)
    get data_requests_start_url(datasets(:orgthree_crowd))
    assert_redirected_to data_requests_proof_url(@simple_started)
  end

  test "should get start and redirect with existing data request" do
    login(@regular)
    get data_requests_start_url(@released)
    assert_redirected_to data_requests_page_url(@started, 1)
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
    assert_redirected_to data_requests_page_url(@started, 1)
  end

  test "should update request as organization" do
    login(@regular)
    post data_requests_update_individual_or_organization_url(@released, data_user_type: "organization")
    @regular.reload
    assert_equal "organization", @regular.data_user_type
    assert_redirected_to data_requests_page_url(@started, 1)
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
    assert_redirected_to data_requests_page_url(@started, 1)
  end

  test "should update intended use commercial" do
    login(@regular)
    post data_requests_update_noncommercial_or_commercial_url(@released, commercial_type: "commercial")
    @regular.reload
    assert_equal "commercial", @regular.commercial_type
    assert_redirected_to data_requests_page_url(@started, 1)
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

  test "should get designate duly authorized representative" do
    login(@regular)
    get data_requests_duly_authorized_representative_url(@started)
    assert_response :success
  end

  test "should not get designate duly authorized representative for checkbox attestation legal documents" do
    login(@orgtwo_regular)
    get data_requests_duly_authorized_representative_url(@checkbox_attestestation_started)
    assert_redirected_to data_requests_attest_url(@checkbox_attestestation_started)
  end

  test "should not get designate duly authorized representative for no attestation legal documents" do
    login(@orgthree_regular)
    get data_requests_duly_authorized_representative_url(@simple_started)
    assert_redirected_to data_requests_attest_url(@simple_started)
  end

  test "should get addendum" do
    login(@regular)
    get data_requests_addendum_url(@started, "1")
    assert_response :success
  end

  test "should get proof" do
    login(@regular)
    get data_requests_proof_url(@started)
    assert_response :success
  end

  test "should get submitted" do
    login(users(:two))
    get submitted_data_request_url(agreements(:submitted_application))
    assert_response :success
  end

  test "should get print" do
    login(@regular)
    get print_data_request_url(@started)
    assert_response :success
  end

  test "should get show" do
    # TODO: Get show of data requests with different status, started, submitted, expired (expired other)
    skip
    login(users(:two))
    get submitted_data_request_url(agreements(:submitted_application))
    assert_response :success
  end

  test "should get index as regular user" do
    # TODO: Make sure regular user has data requests in various states.
    login(users(:regular))
    get data_requests_url
    assert_response :success
  end

  test "should not get index as public user" do
    get data_requests_url
    assert_redirected_to new_user_session_path
  end
end
