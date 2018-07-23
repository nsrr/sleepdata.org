# frozen_string_literal: true

require "test_helper"

# Tests to assure that submitted data requests can be reviewed and updated.
class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reviewer = users(:reviewer_on_released)
    @reviewer_two = users(:reviewer_two_on_released)
    @reviewer_three = users(:reviewer_three_on_released)
    @data_request = data_requests(:submitted)
  end

  test "should get index" do
    login(@reviewer)
    get reviews_url
    assert_response :success
    assert_not_nil assigns(:data_requests)
  end

  # Change tags from ["academic", "publication"] to ["academic", "student", "thesis"]
  test "should update agreement tags" do
    login(@reviewer)
    assert_equal [tags(:academic).id, tags(:publication).id].sort, @data_request.tags.pluck(:id).sort
    post update_tags_review_url(@data_request, format: "js"), params: {
      data_request: {
        tag_ids: [tags(:academic).to_param, tags(:student).to_param, tags(:thesis).to_param]
      }
    }
    assert_not_nil assigns(:data_request)
    assert_equal(
      [tags(:academic).id, tags(:student).id, tags(:thesis).id].sort,
      assigns(:data_request).tags.pluck(:id).sort
    )
    assert_not_nil assigns(:agreement_event)
    assert_equal "tags_updated", assigns(:agreement_event).event_type
    assert_equal @reviewer.id, assigns(:agreement_event).user_id
    assert_equal(
      [tags(:student).id, tags(:thesis).id].sort,
      assigns(:agreement_event).agreement_event_tags.where(added: true).pluck(:tag_id).sort
    )
    assert_equal(
      [tags(:publication).id].sort,
      assigns(:agreement_event).agreement_event_tags.where(added: false).pluck(:tag_id).sort
    )
    assert_template "agreement_events/index"
    assert_response :success
  end

  test "should vote and approve agreement" do
    login(@reviewer)
    assert_difference("DataRequestReview.count") do
      post vote_review_url(@data_request, format: "js"), params: { approved: "1" }
    end
    assert_equal true, assigns(:data_request_review).approved
    assert_equal "reviewer_approved", assigns(:agreement_event).event_type
    assert_template "vote"
    assert_response :success
  end

  test "should vote leave comment and approve agreement" do
    login(@reviewer)
    assert_difference("AgreementEvent.count", 2) do
      assert_difference("DataRequestReview.count") do
        post vote_review_url(@data_request, format: "js"), params: { approved: "1", comment: "Approved this request." }
      end
    end
    assert_equal true, assigns(:data_request_review).approved
    assert_equal "reviewer_approved", assigns(:agreement_event).event_type
    assert_template "vote"
    assert_response :success
  end

  test "should vote and reject agreement" do
    login(@reviewer)
    assert_difference("DataRequestReview.count") do
      post vote_review_url(@data_request, format: "js"), params: { approved: "0" }
    end
    assert_equal false, assigns(:data_request_review).approved
    assert_equal "reviewer_rejected", assigns(:agreement_event).event_type
    assert_equal @reviewer, assigns(:data_request_review).user
    assert_template "vote"
    assert_response :success
  end

  test "should not update unchanged vote" do
    login(@reviewer_two)
    assert_difference("DataRequestReview.count", 0) do
      post vote_review_url(@data_request, format: "js"), params: { approved: "0" }
    end
    assert_equal false, assigns(:data_request_review).approved
    assert_nil assigns(:agreement_event)
    assert_template "vote"
    assert_response :success
  end

  test "should change vote to approved" do
    login(@reviewer_two)
    assert_difference("DataRequestReview.count", 0) do
      post vote_review_url(@data_request, format: "js"), params: { approved: "1" }
    end
    assert_equal true, assigns(:data_request_review).approved
    assert_equal "reviewer_changed_from_rejected_to_approved", assigns(:agreement_event).event_type
    assert_template "vote"
    assert_response :success
  end

  test "should change vote to rejected" do
    login(@reviewer_three)
    assert_difference("DataRequestReview.count", 0) do
      post vote_review_url(@data_request, format: "js"), params: { approved: "0" }
    end
    assert_equal false, assigns(:data_request_review).approved
    assert_equal "reviewer_changed_from_approved_to_rejected", assigns(:agreement_event).event_type
    assert_template "vote"
    assert_response :success
  end

  test "should get transactions" do
    login(@reviewer)
    get transactions_review_url(@data_request)
    assert_response :success
  end

  test "should get print" do
    login(@reviewer)
    get print_review_url(@data_request)
    assert_response :success
  end

  test "should reset signature" do
    login(@reviewer)
    delete reset_signature_review_url(data_requests(:started))
    assert_redirected_to review_url(data_requests(:started))
  end
end
