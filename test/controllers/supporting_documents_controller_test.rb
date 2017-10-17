require "test_helper"

class SupportingDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
    @addons = agreements(:addons)
    @supporting_document = supporting_documents(:one)
  end

  def support_document_params
    {
      document: fixture_file_upload("../../test/support/images/rails.png")
    }
  end

  test "should get index" do
    login(@regular)
    get data_request_supporting_documents_url(@addons, format: "js"), xhr: true
    assert_template "index"
    assert_response :success
  end

  test "should get new" do
    login(@regular)
    get new_data_request_supporting_document_url(@addons)
    assert_response :success
  end

  test "should create supporting document" do
    login(@regular)
    assert_difference("SupportingDocument.count") do
      post data_request_supporting_documents_url(@addons), params: { supporting_document: support_document_params }
    end
    assert_redirected_to data_requests_addons_url(@addons)
  end

  test "should upload multiple supporting documents" do
    login(@regular)
    assert_difference("SupportingDocument.count", 2) do
      post upload_data_request_supporting_documents_url(@addons), params: { documents: [fixture_file_upload('../../test/support/images/rails.png'), fixture_file_upload('../../test/support/images/rails.png')], format: "js" }
    end
    assert_template "index"
    assert_response :success
  end

  test "should show supporting document" do
    # TODO: Show files inline
    skip
    login(@regular)
    get data_request_supporting_document_url(@addons, @supporting_document)
    assert_kind_of String, response.body
    assert_equal File.binread(@supporting_document.document.path), response.body
    assert_response :success
  end

  test "should destroy supporting document" do
    login(@regular)
    assert_difference("SupportingDocument.count", -1) do
      delete data_request_supporting_document_url(@addons, @supporting_document, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
