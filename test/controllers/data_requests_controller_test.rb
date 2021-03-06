# frozen_string_literal: true

require "test_helper"

# Test data access request process.
class DataRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @orgtwo_regular = users(:orgtwo_regular)
    @orgthree_regular = users(:orgthree_regular)
    @released = datasets(:released)
    @started = data_requests(:started)
    @checkbox_attestestation_started = data_requests(:checkbox_attestestation_started)
    @simple_started = data_requests(:simple_started)
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

  test "should get page" do
    login(@regular)
    get data_requests_page_url(@started, page: "1")
    assert_response :success
  end

  test "should update page" do
    login(@regular)
    assert_difference("AgreementVariable.count") do
      post data_requests_update_page_url(@started, "1", full_name: "Regular User")
    end
    assert_equal(
      "Regular User",
      @started.agreement_variables.find_by(
        final_legal_document_variable: final_legal_document_variables(:full_name)
      ).value
    )
    assert_redirected_to data_requests_page_url(@started, "2")
  end

  test "should save draft of page" do
    login(@regular)
    assert_difference("AgreementVariable.count") do
      post data_requests_update_page_url(@started, "1", full_name: "Regular User", data_request: { draft: "1" })
    end
    assert_equal(
      "Regular User",
      @started.agreement_variables.find_by(
        final_legal_document_variable: final_legal_document_variables(:full_name)
      ).value
    )
    assert_redirected_to data_requests_page_url(@started, "1")
  end

  test "should get attest" do
    login(@regular)
    get data_requests_attest_url(@started)
    assert_response :success
  end

  test "should update attest with checkbox" do
    data_request = data_requests(:checkbox_attestestation_started)
    login(data_request.user)
    post data_requests_update_attest_url(data_request, attest: "1")
    data_request.reload
    assert_not_nil data_request.attested_at
    assert_redirected_to data_request_supporting_documents_url(data_request)
  end

  test "should update attest with signature" do
    data_request = data_requests(:started)
    login(data_request.user)
    post data_requests_update_attest_url(data_request, data_uri: data_uri_signature, signature_print: "Regular User")
    data_request.reload
    assert_equal true, data_request.signature_file.present?
    assert_equal "Regular User", data_request.signature_print
    assert_not_nil data_request.attested_at
    assert_redirected_to data_request_supporting_documents_url(data_request)
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

  test "should submit completed data request" do
    data_request = data_requests(:completed)
    login(data_request.user)
    post data_requests_submit_url(data_request)
    data_request.reload
    assert_equal "submitted", data_request.status
    assert_not_nil data_request.submitted_at
    assert_not_nil data_request.last_submitted_at
    assert_redirected_to submitted_data_request_url(data_request)
  end

  test "should submit completed data request and auto-approve" do
    data_request = data_requests(:simple_started)
    login(data_request.user)
    post data_requests_submit_url(data_request)
    data_request.reload
    assert_equal "approved", data_request.status
    assert_not_nil data_request.submitted_at
    assert_not_nil data_request.last_submitted_at
    # TODO: Perhaps redirect to "approved" data request location.
    assert_redirected_to submitted_data_request_url(data_request)
  end

  test "should not submit incomplete data request missing attestation" do
    data_request = data_requests(:incomplete_missing_attestation)
    login(data_request.user)
    post data_requests_submit_url(data_request)
    data_request.reload
    assert_equal "started", data_request.status
    assert_nil data_request.submitted_at
    assert_nil data_request.last_submitted_at
    assert_equal "Please fill out all required fields.", flash[:notice]
    assert_redirected_to data_requests_proof_url(data_request)
  end

  test "should not submit incomplete data request missing required variable" do
    data_request = data_requests(:incomplete_missing_required_variable)
    login(data_request.user)
    post data_requests_submit_url(data_request)
    data_request.reload
    assert_equal "started", data_request.status
    assert_nil data_request.submitted_at
    assert_nil data_request.last_submitted_at
    assert_equal "Please fill out all required fields.", flash[:notice]
    assert_redirected_to data_requests_proof_url(data_request)
  end

  test "should not submit incomplete data request missing datasets" do
    data_request = data_requests(:incomplete_missing_datasets)
    login(data_request.user)
    post data_requests_submit_url(data_request)
    data_request.reload
    assert_equal "started", data_request.status
    assert_nil data_request.submitted_at
    assert_nil data_request.last_submitted_at
    assert_redirected_to datasets_url
  end

  test "should get submitted" do
    data_request = data_requests(:submitted)
    login(data_request.user)
    get submitted_data_request_url(data_request)
    assert_response :success
  end

  test "should get print" do
    data_request = data_requests(:submitted)
    login(data_request.user)
    get print_data_request_url(data_request)
    assert_response :success
  end

  test "should get show for started data request" do
    data_request = data_requests(:started)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for submitted data request" do
    data_request = data_requests(:submitted)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for approved data request" do
    data_request = data_requests(:approved)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for resubmit data request" do
    data_request = data_requests(:resubmit)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for expired data request" do
    data_request = data_requests(:expired)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for approved that expired data request" do
    data_request = data_requests(:approved_that_expired)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should get show for closed data request" do
    data_request = data_requests(:closed)
    login(data_request.user)
    get data_request_url(data_request)
    assert_response :success
  end

  test "should not get show for deleted data request" do
    data_request = data_requests(:deleted)
    login(data_request.user)
    get data_request_url(data_request)
    assert_redirected_to datasets_url # TODO: perhaps data_requests_url instead?
  end

  test "should get index with started data request" do
    data_request = data_requests(:started)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with submitted data request" do
    data_request = data_requests(:submitted)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with approved data request" do
    data_request = data_requests(:approved)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with resubmit data request" do
    data_request = data_requests(:resubmit)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with expired data request" do
    data_request = data_requests(:expired)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with approved that expired data request" do
    data_request = data_requests(:approved_that_expired)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with closed data request" do
    data_request = data_requests(:closed)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should get index with deleted data request" do
    data_request = data_requests(:deleted)
    login(data_request.user)
    get data_requests_url
    assert_response :success
  end

  test "should not get index as public user" do
    get data_requests_url
    assert_redirected_to new_user_session_url
  end

  test "should delete started data request" do
    data_request = data_requests(:started)
    login(data_request.user)
    assert_difference("DataRequest.current.count", -1) do
      delete data_request_url(data_request)
    end
    assert_equal "Data request was successfully deleted.", flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should delete resubmit data request" do
    data_request = data_requests(:resubmit)
    login(data_request.user)
    assert_difference("DataRequest.current.count", -1) do
      delete data_request_url(data_request)
    end
    assert_equal "Data request was successfully deleted.", flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should delete closed data request" do
    data_request = data_requests(:closed)
    login(data_request.user)
    assert_difference("DataRequest.current.count", -1) do
      delete data_request_url(data_request)
    end
    assert_equal "Data request was successfully deleted.", flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should not delete submitted data request" do
    data_request = data_requests(:submitted)
    login(data_request.user)
    assert_difference("DataRequest.current.count", 0) do
      delete data_request_url(data_request)
    end
    assert_nil flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should not delete approved data request" do
    data_request = data_requests(:approved)
    login(data_request.user)
    assert_difference("DataRequest.current.count", 0) do
      delete data_request_url(data_request)
    end
    assert_nil flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should not delete expired data request" do
    data_request = data_requests(:expired)
    login(data_request.user)
    assert_difference("DataRequest.current.count", 0) do
      delete data_request_url(data_request)
    end
    assert_nil flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should not delete approved that expired data request" do
    data_request = data_requests(:approved_that_expired)
    login(data_request.user)
    assert_difference("DataRequest.current.count", 0) do
      delete data_request_url(data_request)
    end
    assert_nil flash[:notice]
    assert_redirected_to data_requests_url
  end

  test "should get resume for started data request" do
    data_request = data_requests(:started)
    login(data_request.user)
    get resume_data_request_url(data_request)
    assert_redirected_to data_requests_page_url(data_request, 1)
  end

  test "should get resume for resubmit data request" do
    data_request = data_requests(:resubmit)
    login(data_request.user)
    get resume_data_request_url(data_request)
    assert_redirected_to data_requests_page_url(data_request, 1)
  end
end
