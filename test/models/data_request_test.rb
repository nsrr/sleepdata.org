# frozen_string_literal: true

require "test_helper"

# Checks completeness of data requests.
class DataRequestTest < ActiveSupport::TestCase
  test "check completeness of started data request" do
    data_request = data_requests(:started)
    assert_equal false, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of uploads data request" do
    data_request = data_requests(:uploads)
    assert_equal false, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of data request that requests duly authorized representative signature" do
    data_request = data_requests(:duly_authorized_signature_requested)
    assert_equal false, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of completed data request" do
    data_request = data_requests(:completed)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of complete with duly authorized representative signature data request" do
    data_request = data_requests(:completed_with_duly_authorized_representative_signature)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of incomplete missing attestation data request" do
    data_request = data_requests(:incomplete_missing_attestation)
    assert_equal false, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of incomplete missing required variable data request" do
    data_request = data_requests(:incomplete_missing_required_variable)
    assert_equal true, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of incomplete_missing_datasets data request" do
    data_request = data_requests(:incomplete_missing_datasets)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of submitted data request" do
    data_request = data_requests(:submitted)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of approved data request" do
    data_request = data_requests(:approved)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of resubmit data request" do
    data_request = data_requests(:resubmit)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of resubmitted data request" do
    data_request = data_requests(:resubmitted)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of expired data request" do
    data_request = data_requests(:expired)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of approved_that_expired data request" do
    data_request = data_requests(:approved_that_expired)
    assert_equal true, data_request.attestation_complete?
    assert_equal true, data_request.pages_complete?
    assert_equal true, data_request.complete?
  end

  test "check completeness of closed data request" do
    data_request = data_requests(:closed)
    assert_equal false, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end

  test "check completeness of deleted data request" do
    data_request = data_requests(:deleted)
    assert_equal false, data_request.attestation_complete?
    assert_equal false, data_request.pages_complete?
    assert_equal false, data_request.complete?
  end
end
