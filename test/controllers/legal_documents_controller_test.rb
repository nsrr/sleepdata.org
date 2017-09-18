require 'test_helper'

class LegalDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @legal_document = legal_documents(:one)
    @admin = users(:admin)
  end

  def legal_document_params
    {
      name: "Data Access and Use Agreement",
      slug: "daua",
      commercial_type: "noncommercial",
      data_user_type: "individual",
      attestation_type: "checkbox",
      approval_process: "committee"
    }
  end

  test "should get index" do
    login(@admin)
    get organization_legal_documents_url(@organization)
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_organization_legal_document_url(@organization)
    assert_response :success
  end

  test "should create legal document" do
    login(@admin)
    assert_difference('LegalDocument.count') do
      post organization_legal_documents_url(@organization), params: { legal_document: legal_document_params }
    end
    assert_redirected_to organization_legal_document_url(@organization, LegalDocument.last)
  end

  test "should show legal document" do
    login(@admin)
    get organization_legal_document_url(@organization, @legal_document)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_organization_legal_document_url(@organization, @legal_document)
    assert_response :success
  end

  test "should update legal document" do
    login(@admin)
    patch organization_legal_document_url(@organization, @legal_document), params: { legal_document: legal_document_params.merge(slug: "daua-updated") }
    assert_redirected_to organization_legal_document_url(@organization, "daua-updated")
  end

  test "should destroy legal document" do
    login(@admin)
    assert_difference('LegalDocument.current.count', -1) do
      delete organization_legal_document_url(@organization, @legal_document)
    end
    assert_redirected_to organization_legal_documents_url(@organization)
  end
end
