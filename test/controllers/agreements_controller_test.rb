# frozen_string_literal: true

require "test_helper"

# Allows reviewers to review data requests.
class AgreementsControllerTest < ActionController::TestCase
  setup do
    @data_request = data_requests(:submitted)
  end

  # TODO: Remove deprecated step wizard
  test "should download irb pdf for system admin" do
    skip
    login(users(:admin))
    get :download_irb, params: { id: data_requests(:filled_out_application_with_attached_irb_file) }
    assert_not_nil assigns(:data_request)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(Rails.root.join("test", "support", "data_requests", "blank.pdf")),
      response.body
    )
    assert_response :success
  end

  test "should destroy submission for agreement user for agreements with started or resubmit status" do
    skip
    login(users(:valid))
    assert_difference("Agreement.current.count", -1) do
      delete :destroy_submission, params: { id: data_requests(:filled_out_application_with_attached_irb_file) }
    end
    assert_not_nil assigns(:agreement)
    assert_redirected_to submissions_path
  end

  test "should not destroy submission for non-agreement user for agreements with started or resubmit status" do
    skip
    login(users(:two))
    assert_difference("Agreement.current.count", 0) do
      delete :destroy_submission, params: { id: data_requests(:filled_out_application_with_attached_irb_file) }
    end
    assert_nil assigns(:agreement)
    assert_redirected_to submissions_path
  end

  # Older Agreements

  # deprecated
  test "should get index" do
    login(users(:admin))
    get :index
    assert_redirected_to reviews_path
  end

  # deprecated
  test "should show agreement" do
    login(users(:admin))
    get :show, params: { id: @data_request }
    assert_redirected_to reviews_path
  end

  test "should download pdf" do
    skip
    login(users(:admin))
    get :download, params: { id: @data_request }
    assert_not_nil assigns(:agreement)
    assert_kind_of String, response.body
    assert_equal File.binread(Rails.root.join("test", "support", "data_requests", "blank.pdf")), response.body
    assert_response :success
  end

  test "should update agreement and set as approved" do
    skip
    login(users(:admin))
    patch :update, params: {
      id: data_requests(:two),
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
    assert_redirected_to review_path(assigns(:data_request), anchor: "c#{assigns("data_request").agreement_events.last.number}")
  end

  test "should update agreement and ask user to resubmit" do
    login(users(:admin))
    patch :update, params: { id: @data_request, data_request: { status: "resubmit", comments: "Please Resubmit" } }
    assert_not_nil assigns(:data_request)
    assert_equal "resubmit", assigns(:data_request).status
    assert_equal "Please Resubmit", assigns(:data_request).comments
    assert_redirected_to review_path(assigns(:data_request), anchor: "c#{assigns("data_request").agreement_events.last.number}")
  end

  test "should not approve agreement without required fields" do
    skip
    login(users(:admin))
    patch :update, params: { id: @data_request, data_request: { approval_date: "", expiration_date: "", reviewer_signature: "[]", status: "approved" } }
    assert_not_nil assigns(:data_request)
    assert_equal ["can't be blank"], assigns(:data_request).errors[:approval_date]
    assert_equal ["can't be blank"], assigns(:data_request).errors[:expiration_date]
    assert_equal ["can't be blank"], assigns(:data_request).errors[:edges_in_reviewer_signature]
    assert_template "reviews/show"
  end

  test "should not update agreement and ask user to resubmit without comments" do
    login(users(:admin))
    patch :update, params: { id: @data_request, data_request: { status: "resubmit", comments: "" } }
    assert_not_nil assigns(:data_request)
    assert_equal ["can't be blank"], assigns(:data_request).errors[:comments]
    assert_template "reviews/show"
  end

  test "should destroy agreement" do
    login(users(:admin))
    assert_difference("Agreement.current.count", -1) do
      delete :destroy, params: { id: @data_request }
    end
    assert_redirected_to agreements_path
  end
end
