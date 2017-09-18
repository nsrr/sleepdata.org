# frozen_string_literal: true

require "test_helper"

# Test that organization editors can create and modify legal document pages.
class LegalDocumentPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @legal_document = legal_documents(:one)
    @legal_document_page = legal_document_pages(:one)
    @admin = users(:admin)
  end

  def legal_document_page_params
    {
      title: "More information",
      readable_content: "Provide more information:\n<more_information>",
      position: "3",
      rider: "0"
    }
  end

  test "should get index" do
    login(@admin)
    get organization_legal_document_legal_document_pages_url(@organization, @legal_document)
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_organization_legal_document_legal_document_page_url(@organization, @legal_document)
    assert_response :success
  end

  test "should create legal document page" do
    login(@admin)
    assert_difference("LegalDocumentPage.count") do
      post organization_legal_document_legal_document_pages_url(@organization, @legal_document), params: { legal_document_page: legal_document_page_params }
    end
    assert_equal "Provide more information:\n<more_information>", LegalDocumentPage.last.readable_content
    assert_redirected_to organization_legal_document_legal_document_page_url(@organization, @legal_document, LegalDocumentPage.last)
  end

  test "should show legal document page" do
    login(@admin)
    get organization_legal_document_legal_document_page_url(@organization, @legal_document, @legal_document_page)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_organization_legal_document_legal_document_page_url(@organization, @legal_document, @legal_document_page)
    assert_response :success
  end

  test "should update legal document page" do
    login(@admin)
    patch organization_legal_document_legal_document_page_url(@organization, @legal_document, @legal_document_page), params: { legal_document_page: legal_document_page_params }
    @legal_document_page.reload
    assert_equal "Provide more information:\n<more_information>", @legal_document_page.readable_content
    assert_redirected_to organization_legal_document_legal_document_page_url(@organization, @legal_document, @legal_document_page)
  end

  test "should destroy legal document page" do
    login(@admin)
    assert_difference("LegalDocumentPage.current.count", -1) do
      delete organization_legal_document_legal_document_page_url(@organization, @legal_document, @legal_document_page)
    end
    assert_redirected_to organization_legal_document_legal_document_pages_url(@organization, @legal_document)
  end
end
