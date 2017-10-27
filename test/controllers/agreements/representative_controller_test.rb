# frozen_string_literal: true

require "test_helper"

# Tests to assure that duly authorized representatives can view and sign data
# access and use agreement on behalf of the data user.
class Agreements::RepresentativeControllerTest < ActionController::TestCase
  setup do
    @agreement = agreements(:sign_by_representative)
  end

  def agreement_params
    {
      duly_authorized_representative_signature_print: "Duly Authorized",
      duly_authorized_representative_signature_date: "3/23/2016",
      duly_authorized_representative_title: "Duly Title"
    }
  end

  test "should get signature requested" do
    get :signature_requested, params: {
      representative_token: @agreement.id_and_representative_token
    }
    assert_response :success
  end

  test "should submit signature" do
    patch :submit_signature, params: {
      representative_token: @agreement.id_and_representative_token,
      data_uri: data_uri_signature,
      agreement: agreement_params
    }
    assert_redirected_to representative_signature_submitted_path
  end

  test "should not submit signature with missing fields" do
    skip
    patch :submit_signature, params: {
      representative_token: @agreement.id_and_representative_token,
      data_uri: data_uri_signature,
      agreement: agreement_params.merge(duly_authorized_representative_signature_print: "")
    }
    assert_template "signature_requested"
    assert_response :success
  end

  test "should get signature submitted" do
    get :signature_submitted
    assert_response :success
  end
end
