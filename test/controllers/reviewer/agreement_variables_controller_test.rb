# frozen_string_literal: true

require "test_helper"

# Tests to assure reviewers can mark agreement variables for resubmission.
class Reviewer::AgreementVariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reviewer = users(:reviewer_on_released)
    @submitted = data_requests(:submitted)
    @specific_purpose = agreement_variables(:submitted_specific_purpose)
  end

  def agreement_variable_params
    {
      reviewer_comment: "Please be more specific."
    }
  end

  test "should update review" do
    login(@reviewer)
    patch reviewer_agreement_variable_url(@submitted, @specific_purpose, format: "js"), params: {
      agreement_variable: agreement_variable_params
    }
    @specific_purpose.reload
    assert_equal true, @specific_purpose.resubmission_required?
    assert_equal "Please be more specific.", @specific_purpose.reviewer_comment
    assert_template "show"
    assert_response :success
  end
end
