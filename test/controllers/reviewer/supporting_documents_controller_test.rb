# frozen_string_literal: true

require "test_helper"

# Tests to assure that submitted data requests can be reviewed and updated.
class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reviewer = users(:reviewer_on_released)
    @uploads = data_requests(:uploads)
  end

  def supporting_document_params
    {
      document: fixture_file_upload("../../test/support/images/rails.png")
    }
  end

  test "should get supporting document" do
    login(@reviewer)
    get reviewer_supporting_document_url(@uploads, supporting_documents(:one))
    assert_equal File.binread(supporting_documents(:one).document.path), response.body
    assert_response :success
  end

  test "should get supporting documents" do
    login(@reviewer)
    get reviewer_supporting_documents_url(@uploads)
    assert_response :success
  end

  test "should get new supporting document" do
    login(@reviewer)
    get new_reviewer_supporting_document_url(@uploads)
    assert_response :success
  end

  test "should create supporting document" do
    login(@reviewer)
    assert_difference("SupportingDocument.where(reviewer_uploaded: true).count") do
      post reviewer_supporting_documents_url(@uploads), params: {
        supporting_document: supporting_document_params
      }
    end
    assert_redirected_to reviewer_supporting_documents_url(@uploads)
  end

  test "should upload multiple supporting documents" do
    login(@reviewer)
    assert_difference("SupportingDocument.where(reviewer_uploaded: true).count", 2) do
      post upload_reviewer_supporting_documents_url(@uploads, format: "js"), params: {
        documents: [
          fixture_file_upload("../../test/support/images/rails.png"),
          fixture_file_upload("../../test/support/images/rails.png")
        ]
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should destroy supporting document uploaded by data request user" do
    login(@reviewer)
    assert_difference("SupportingDocument.count", -1) do
      delete reviewer_supporting_document_url(@uploads, supporting_documents(:two), format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end

  test "should destroy supporting document uploaded by reviewer" do
    login(@reviewer)
    assert_difference("SupportingDocument.count", -1) do
      delete reviewer_supporting_document_url(
        @uploads, supporting_documents(:reviewer_uploaded), format: "js"
      )
    end
    assert_template "destroy"
    assert_response :success
  end
end
