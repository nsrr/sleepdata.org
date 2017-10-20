# frozen_string_literal: true

require "test_helper"

# Assure that users can upload supporting documents to data requests.
class SupportingDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular2 = users(:regular2)
    @uploads = agreements(:uploads)
    @supporting_document = supporting_documents(:one)
  end

  def support_document_params
    {
      document: fixture_file_upload("../../test/support/images/rails.png")
    }
  end

  test "should get index" do
    login(@regular2)
    get data_request_supporting_documents_url(@uploads)
    assert_template "index"
    assert_response :success
  end

  test "should get index using ajax" do
    login(@regular2)
    get data_request_supporting_documents_url(@uploads, format: "js"), xhr: true
    assert_template "index"
    assert_response :success
  end

  test "should get new" do
    login(@regular2)
    get new_data_request_supporting_document_url(@uploads)
    assert_response :success
  end

  test "should create supporting document" do
    login(@regular2)
    assert_difference("SupportingDocument.count") do
      post data_request_supporting_documents_url(@uploads), params: { supporting_document: support_document_params }
    end
    assert_redirected_to data_request_supporting_documents_url(@uploads)
  end

  test "should upload multiple supporting documents" do
    login(@regular2)
    assert_difference("SupportingDocument.count", 2) do
      post upload_data_request_supporting_documents_url(@uploads), params: {
        documents: [
          fixture_file_upload('../../test/support/images/rails.png'),
          fixture_file_upload('../../test/support/images/rails.png')
        ],
        format: "js"
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should show supporting document" do
    # TODO: Show files inline
    skip
    login(@regular2)
    get data_request_supporting_document_url(@uploads, @supporting_document)
    assert_kind_of String, response.body
    assert_equal File.binread(@supporting_document.document.path), response.body
    assert_response :success
  end

  test "should destroy supporting document" do
    login(@regular2)
    assert_difference("SupportingDocument.count", -1) do
      delete data_request_supporting_document_url(@uploads, @supporting_document, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
