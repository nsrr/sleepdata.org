# frozen_string_literal: true

require "test_helper"

# Assure that data requests events can be created and viewed.
class AgreementEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @submitted = data_requests(:submitted)
    @admin = users(:admin)
    @reviewer = users(:reviewer_on_released)
    @reviewer_comment = agreement_events(:submitted_two_comment)
    @reviewer_two = users(:reviewer_two_on_released)
  end

  test "should create data request comment" do
    login(@reviewer)
    assert_difference("AgreementEvent.count") do
      post agreement_agreement_events_url(@submitted, format: "js"), params: {
        agreement_event: {
          comment: "I reviewed this data access request, cc @reviewer_two_on_released."
        }
      }
    end
    assert_equal "I reviewed this data access request, cc @reviewer_two_on_released.", assigns(:agreement_event).comment
    assert_template "create"
    assert_response :success
  end

  test "should not create blank data request comment" do
    login(@reviewer)
    assert_difference("AgreementEvent.count", 0) do
      post agreement_agreement_events_url(@submitted, format: "js"), params: {
        agreement_event: { comment: "" }
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create data request comment as public user" do
    assert_difference("AgreementEvent.count", 0) do
      post agreement_agreement_events_url(@submitted, format: "js"), params: {
        agreement_event: { comment: "I am not logged in." }
      }
    end
    assert_template nil
    assert_response :unauthorized
  end

  test "should get edit" do
    login(@reviewer)
    get edit_agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), xhr: true
    assert_not_nil assigns(:data_request)
    assert_not_nil assigns(:agreement_event)
    assert_template "edit"
    assert_response :success
  end

  test "should not get edit as another user" do
    login(@reviewer_two)
    get edit_agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), xhr: true
    assert_not_nil assigns(:data_request)
    assert_nil assigns(:agreement_event)
    assert_response :success
  end

  test "should preview comment" do
    login(@reviewer)
    post preview_agreement_agreement_events_url(@submitted, @reviewer_comment, format: "js"), params: {
      agreement_event: { comment: "Preview this for **formatting**." }
    }
    assert_template "preview"
    assert_response :success
  end

  test "should preview new comment" do
    login(@reviewer)
    post preview_agreement_agreement_events_url(@submitted, format: "js"), params: {
      agreement_event: { comment: "Preview this for **formatting**." }
    }
    assert_template "preview"
    assert_response :success
  end

  test "should show comment" do
    login(@reviewer)
    get agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), xhr: true
    assert_template "show"
    assert_response :success
  end

  test "should update comment" do
    login(@reviewer)
    patch agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), params: {
      agreement_event: { comment: "Updated Description" }
    }
    assert_not_nil assigns(:data_request)
    assert_not_nil assigns(:agreement_event)
    assert_equal "Updated Description", assigns(:agreement_event).comment
    assert_template "show"
    assert_response :success
  end

  test "should not update with blank comment" do
    login(@reviewer)
    patch agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), params: {
      agreement_event: { comment: "" }
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update as another user" do
    login(@reviewer_two)
    patch agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js"), params: {
      agreement_event: { comment: "Updated Description" }
    }
    assert_not_nil assigns(:data_request)
    assert_nil assigns(:agreement_event)
    assert_template nil
    assert_response :success
  end

  test "should destroy comment as admin" do
    login(@admin)
    assert_difference("AgreementEvent.current.count", -1) do
      delete agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js")
    end
    assert_not_nil assigns(:data_request)
    assert_template "destroy"
    assert_response :success
  end

  test "should destroy comment as comment author" do
    login(@reviewer)
    assert_difference("AgreementEvent.current.count", -1) do
      delete agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js")
    end
    assert_not_nil assigns(:data_request)
    assert_template "destroy"
    assert_response :success
  end

  test "should not destroy comment as another user" do
    login(@reviewer_two)
    assert_difference("AgreementEvent.current.count", 0) do
      delete agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js")
    end
    assert_template nil
    assert_response :success
  end

  test "should not destroy comment as public user" do
    assert_difference("AgreementEvent.current.count", 0) do
      delete agreement_agreement_event_url(@submitted, @reviewer_comment, format: "js")
    end
    assert_template nil
    assert_response :unauthorized
  end
end
