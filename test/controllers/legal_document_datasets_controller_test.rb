# frozen_string_literal: true

require "test_helper"

# Assure that organization editors can assign legal documents to datasets.
class LegalDocumentDatasetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @legal_document_dataset = legal_document_datasets(:one)
    @admin = users(:admin)
  end

  def legal_document_dataset_params
    {
      legal_document_id: legal_documents(:one).id,
      dataset_id: datasets(:public_with_no_files_folder).id
    }
  end

  test "should get index" do
    login(@admin)
    get organization_legal_document_datasets_url(@organization)
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_organization_legal_document_dataset_url(@organization)
    assert_response :success
  end

  test "should create legal document dataset" do
    login(@admin)
    assert_difference("LegalDocumentDataset.count") do
      post organization_legal_document_datasets_url(@organization), params: { legal_document_dataset: legal_document_dataset_params }
    end
    assert_redirected_to organization_legal_document_dataset_url(@organization, LegalDocumentDataset.last)
  end

  test "should show legal document dataset" do
    login(@admin)
    get organization_legal_document_dataset_url(@organization, @legal_document_dataset)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_organization_legal_document_dataset_url(@organization, @legal_document_dataset)
    assert_response :success
  end

  test "should update legal document dataset" do
    login(@admin)
    patch organization_legal_document_dataset_url(@organization, @legal_document_dataset), params: { legal_document_dataset: legal_document_dataset_params }
    assert_redirected_to organization_legal_document_dataset_url(@organization, @legal_document_dataset)
  end

  test "should destroy legal document dataset" do
    login(@admin)
    assert_difference("LegalDocumentDataset.count", -1) do
      delete organization_legal_document_dataset_url(@organization, @legal_document_dataset)
    end
    assert_redirected_to organization_legal_document_datasets_url(@organization)
  end
end
