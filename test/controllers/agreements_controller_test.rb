# frozen_string_literal: true

require "test_helper"

# Allows reviewers to review data requests.
class AgreementsControllerTest < ActionController::TestCase
  setup do
    @data_request = data_requests(:submitted)
  end

  # TODO: Remove deprecated redirects
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
  # END TODO

  test "should update agreement and set as approved" do
    login(users(:admin))
    patch :update, params: {
      id: @data_request,
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
    login(users(:admin))
    patch :update, params: { id: @data_request, data_request: { approval_date: "", expiration_date: "", reviewer_signature: "[]", status: "approved" } }
    assert_not_nil assigns(:data_request)
    assert_equal ["can't be blank"], assigns(:data_request).errors[:approval_date]
    assert_equal ["can't be blank"], assigns(:data_request).errors[:expiration_date]
    assert_equal false, assigns(:data_request).reviewer_signature_file.present?
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
