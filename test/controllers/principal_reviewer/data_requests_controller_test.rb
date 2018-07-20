# frozen_string_literal: true

require "test_helper"

# Test to assure that principal reviewers can approve/close data requests and
# add and remove datasets from data requests.
class PrincipalReviewer::DataRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @data_request = data_requests(:submitted)
    @principal_reviewer = users(:principal_reviewer_on_released)
  end

  test "should update data request and set as approved" do
    login(@principal_reviewer)
    patch review_data_request_url(@data_request), params: {
      data_request: {
        status: "approved",
        approval_date: "09/20/2014",
        expiration_date: "09/20/2017"
      },
      data_uri: data_uri_signature
    }
    assert_not_nil assigns(:data_request)
    assert_equal "09/20/2014", assigns(:data_request).approval_date.strftime("%m/%d/%Y")
    assert_equal "09/20/2017", assigns(:data_request).expiration_date.strftime("%m/%d/%Y")
    assert_equal true, assigns(:data_request).reviewer_signature_file.present?
    assert_equal "approved", assigns(:data_request).status
    assert_redirected_to review_url(
      assigns(:data_request), anchor: "c#{assigns("data_request").agreement_events.last.number}"
    )
  end

  test "should update data request and ask user to resubmit" do
    login(@principal_reviewer)
    patch review_data_request_url(@data_request), params: {
      data_request: {
        status: "resubmit",
        comments: "Please Resubmit"
      }
    }
    assert_not_nil assigns(:data_request)
    assert_equal "resubmit", assigns(:data_request).status
    assert_equal "Please Resubmit", assigns(:data_request).comments
    assert_redirected_to review_url(
      assigns(:data_request), anchor: "c#{assigns("data_request").agreement_events.last.number}"
    )
  end

  test "should not approve data request without required fields" do
    login(@principal_reviewer)
    patch review_data_request_url(@data_request), params: {
      data_request: {
        status: "approved",
        approval_date: "",
        expiration_date: ""
      }
    }
    assert_not_nil assigns(:data_request)
    assert_equal ["can't be blank"], assigns(:data_request).errors[:approval_date]
    assert_equal ["can't be blank"], assigns(:data_request).errors[:expiration_date]
    assert_equal false, assigns(:data_request).reviewer_signature_file.present?
    assert_template "reviews/show"
    assert_response :success
  end

  test "should not update data request and ask user to resubmit without comments" do
    login(@principal_reviewer)
    patch review_data_request_url(@data_request), params: { data_request: { status: "resubmit", comments: "" } }
    assert_not_nil assigns(:data_request)
    assert_equal ["can't be blank"], assigns(:data_request).errors[:comments]
    assert_template "reviews/show"
    assert_response :success
  end

  # TODO: Reimplement destroy for principal reviewer.
  test "should destroy data request" do
    skip
    login(@principal_reviewer)
    assert_difference("DataRequest.current.count", -1) do
      delete delete_data_request_url(@data_request)
    end
    assert_redirected_to reviews_url
  end
end
