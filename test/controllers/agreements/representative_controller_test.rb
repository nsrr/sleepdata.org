# frozen_string_literal: true

require "test_helper"

# Tests to assure that duly authorized representatives can view and sign data
# request on behalf of the data user.
class Agreements::RepresentativeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data_request = data_requests(:duly_authorized_signature_requested)
  end

  def data_request_params
    {
      duly_authorized_representative_signature_print: "Duly Authorized",
      duly_authorized_representative_signature_date: "3/23/2016",
      duly_authorized_representative_title: "Duly Title"
    }
  end

  test "should get signature requested" do
    get representative_signature_requested_url(@data_request.id_and_representative_token)
    assert_response :success
  end

  test "should submit signature" do
    patch representative_submit_signature_url(@data_request.id_and_representative_token), params: {
      data_uri: data_uri_signature,
      data_request: data_request_params
    }
    assert_redirected_to representative_signature_submitted_url
  end

  test "should not submit signature with missing fields" do
    skip
    patch representative_submit_signature_url(@data_request.id_and_representative_token), params: {
      data_uri: data_uri_signature,
      data_request: data_request_params.merge(duly_authorized_representative_signature_print: "")
    }
    assert_template "signature_requested"
    assert_response :success
  end

  test "should get signature submitted" do
    get representative_signature_submitted_url
    assert_response :success
  end
end
