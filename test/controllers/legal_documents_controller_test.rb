# frozen_string_literal: true

require "test_helper"

# Organization editors should be able to create and edit legal documents.
class LegalDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @legal_document = legal_documents(:one)
    @org_editor = users(:editor)
  end

  def legal_document_params
    {
      name: "Data Access and Use Agreement",
      slug: "daua",
      commercial_type: "noncommercial",
      data_user_type: "individual",
      attestation_type: "signature",
      approval_process: "committee"
    }
  end

  test "should get index" do
    login(@org_editor)
    get organization_legal_documents_url(@organization)
    assert_response :success
  end

  test "should get new" do
    login(@org_editor)
    get new_organization_legal_document_url(@organization)
    assert_response :success
  end

  test "should create legal document" do
    login(@org_editor)
    assert_difference("LegalDocument.count") do
      post organization_legal_documents_url(@organization), params: {
        legal_document: legal_document_params
      }
    end
    assert_redirected_to organization_legal_document_url(@organization, LegalDocument.last)
  end

  test "should show legal document" do
    login(@org_editor)
    get organization_legal_document_url(@organization, @legal_document)
    assert_response :success
  end

  test "should get edit" do
    login(@org_editor)
    get edit_organization_legal_document_url(@organization, @legal_document)
    assert_response :success
  end

  test "should update legal document" do
    login(@org_editor)
    patch organization_legal_document_url(@organization, @legal_document), params: {
      legal_document: legal_document_params.merge(slug: "daua-updated")
    }
    assert_redirected_to organization_legal_document_url(@organization, "daua-updated")
  end

  test "should destroy legal document" do
    login(@org_editor)
    assert_difference("LegalDocument.current.count", -1) do
      delete organization_legal_document_url(@organization, @legal_document)
    end
    assert_redirected_to organization_legal_documents_url(@organization)
  end
end
