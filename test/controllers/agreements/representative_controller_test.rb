# frozen_string_literal: true

require 'test_helper'

# Tests to assure that duly authorized representatives can view and sign data
# access and use agreement on behalf of the data user.
class Agreements::RepresentativeControllerTest < ActionController::TestCase
  setup do
    @agreement = agreements(:sign_by_representative)
  end

  def agreement_params
    {
      current_step: '4',
      duly_authorized_representative_signature_print: 'Duly Authorized',
      duly_authorized_representative_signature: signature,
      duly_authorized_representative_signature_date: '3/23/2016',
      duly_authorized_representative_title: 'Duly Title'
    }
  end

  def signature
    "[{\"lx\":22,\"ly\":17,\"mx\":22,\"my\":16},{\"lx\":21,\"ly\":18,\"mx\":22,\"my\":17},
      {\"lx\":21,\"ly\":19,\"mx\":21,\"my\":18},{\"lx\":20,\"ly\":22,\"mx\":21,\"my\":19},
      {\"lx\":19,\"ly\":25,\"mx\":20,\"my\":22},{\"lx\":19,\"ly\":28,\"mx\":19,\"my\":25},
      {\"lx\":19,\"ly\":29,\"mx\":19,\"my\":28},{\"lx\":19,\"ly\":30,\"mx\":19,\"my\":29},
      {\"lx\":18,\"ly\":32,\"mx\":19,\"my\":30},{\"lx\":18,\"ly\":34,\"mx\":18,\"my\":32},
      {\"lx\":16,\"ly\":35,\"mx\":18,\"my\":34},{\"lx\":16,\"ly\":38,\"mx\":16,\"my\":35},
      {\"lx\":16,\"ly\":39,\"mx\":16,\"my\":38},{\"lx\":16,\"ly\":40,\"mx\":16,\"my\":39},
      {\"lx\":15,\"ly\":41,\"mx\":16,\"my\":40},{\"lx\":13,\"ly\":44,\"mx\":15,\"my\":41},
      {\"lx\":13,\"ly\":46,\"mx\":13,\"my\":44},{\"lx\":13,\"ly\":47,\"mx\":13,\"my\":46},
      {\"lx\":26,\"ly\":15,\"mx\":24,\"my\":15},{\"lx\":28,\"ly\":14,\"mx\":26,\"my\":15}]"
  end

  test 'should get signature requested' do
    get :signature_requested, params: {
      representative_token: @agreement.id_and_representative_token
    }
    assert_response :success
  end

  test 'should submit signature' do
    patch :submit_signature, params: {
      representative_token: @agreement.id_and_representative_token,
      agreement: agreement_params
    }
    assert_redirected_to representative_signature_submitted_path
  end

  test 'should not submit signature with missing fields' do
    skip
    patch :submit_signature, params: {
      representative_token: @agreement.id_and_representative_token,
      agreement: agreement_params.merge(duly_authorized_representative_signature_print: '')
    }
    assert_template 'signature_requested'
    assert_response :success
  end

  test 'should get signature submitted' do
    get :signature_submitted
    assert_response :success
  end
end
